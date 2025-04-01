{
  lib,
  pkgs,
  files,
  ...
}: let
  inherit (lib) licenses recursiveUpdate;

  help = ''
    # Legend #
      xxx - Command [action]         - Description

    # Usage #
      help                           - Show this information
      brightness [up,down]           - Screen Brightness Controls
      temperature [up,down]          - Display Temperature Controls
      backlight [up,down]            - Keyboard Backlight Controls
      volume [up,down,mute]          - Volume Controls
      media [next,previous,toggle]   - Media Controls
      zoom [in,out]                  - Screen Zoom
      toggle 
        fancy                        - Toggle Compositor Effects
        float                        - Toggle window floating in current workspace
        minimized                    - Show minimized windows
        monitor                      - Toggle specified Monitor
        service ['name']             - Toggle SystemD Service
        shader                       - Toggle Compositor Shader
        touchpad                     - Toggle touchpad
  '';

  daemon = builtins.toFile "daemon.sh" ''
    event_activespecial() {
      case "$WORKSPACENAME" in
      special:minimized*)
        hyprctl dispatch submap reset
        hyprctl dispatch submap Minimized
      ;;
      esac
    }

    event_minimized() {
      WINDOW="address:0x$WINDOWADDRESS"
      case "$MINIMIZED" in
      0) hyprctl dispatch movetoworkspace "+0, $WINDOW" ;;
      1) hyprctl dispatch movetoworkspacesilent "special:minimized, $WINDOW" ;;
      esac
    }
  '';
in
  recursiveUpdate {
    meta = {
      mainProgram = "hyprutils";
      description = "Hyprland Utility Script";
      homepage = files.path.repo;
      license = licenses.gpl3Only;
      maintainers = ["maydayv7"];
    };
  } (pkgs.writeShellApplication {
    name = "hyprutils";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      socat
      wget

      dunst
      zenity
      hyprshade
      hyprsunset
      hyprland
      custom.hyprshellevents

      alsa-utils
      brightnessctl
      brillo
      libnotify
      playerctl
      systemd
    ];

    text = ''
      set +eu
      ${files.scripts.commands}
      show_album_art=true
      show_music_in_volume_indicator=true

      notify() {
        notify-send -a "utility" -t 1000 -h string:x-dunst-stack-tag:"$1" "''${@:2}"
      }

      get_media_icon() {
        media_icon="audio-speakers"
        if $show_album_art
        then
          temp media-icon 1
          url=$(playerctl -f "{{mpris:artUrl}}" metadata)
          if [[ "$url" == "file://"* ]]
          then
            media_icon="''${url/file:\/\//}"
          elif [[ "$url" == "http://"* ]] || [[ "$url" == "https://"* ]]
          then
            filename="$(echo "$url" | sed "s/.*\///")"
            if [ ! -f "$TEMP/$filename" ]; then wget -O "$TEMP/$filename" "$url"; fi
            media_icon="$TEMP/$filename"
          fi
        fi
      }

      case "$1" in
        "") error "Expected an Option" "${help}";;
        "help") echo -e "## Hyprland Utility Script ##\n${help}";;
        "daemon")
          info "Monitoring Hyprland Socket..."
          socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock EXEC:"shellevents ${daemon}",nofork
        ;;
        "brightness")
          brightness_notification() {
            brightness=$(brillo | grep -Po '[0-9]{1,3}' | head -n 1)
            notify brightness -i "display" -h int:value:"$brightness" " $brightness%"
          }
          case "$2" in
          "up")
            brillo -u 300000 -A 5
            brightness_notification
          ;;
          "down")
            brillo -u 300000 -U 5
            brightness_notification
          ;;
          "") error "Expected an Option" "Try 'hyprutils help' for more information" ;;
          *) error "Unexpected Option 'brightness $2'" "Try 'hyprutils help' for more information" ;;
          esac
        ;;
        "backlight")
          backlight_notification() {
            backlight="$(cat /sys/class/leds/*::kbd_backlight/brightness)"
            light=0; if [ "$backlight" -eq 1 ]; then light=33; fi
            if [ "$backlight" -eq 2 ]; then light=67; fi
            if [ "$backlight" -eq 3 ]; then light=100; fi
            notify backlight -i "keyboard" -h int:value:"$light" " $light%"
          }
          case "$2" in
          "up")
            brightnessctl -d "*::kbd_backlight" set 33%+
            backlight_notification
          ;;
          "down")
            brightnessctl -d "*::kbd_backlight" set 33%-
            backlight_notification
          ;;
          "") error "Expected an Option" "Try 'hyprutils help' for more information" ;;
          *) error "Unexpected Option 'brightness $2'" "Try 'hyprutils help' for more information" ;;
          esac
        ;;
        "temperature")
          if [[ ! $(pgrep hyprsunset) ]]
          then
            hyprsunset -i &
          fi
          temperature_notification() {
            temperature=$(hyprctl hyprsunset temperature)
            notify temperature -i "display" " $temperature K"
          }
          case "$2" in
          "up")
            hyprctl hyprsunset temperature +200
            temperature_notification
          ;;
          "down")
            hyprctl hyprsunset temperature -200
            temperature_notification
          ;;
          "reset")
            hyprctl hyprsunset temperature 6000
            hyprctl hyprsunset identity
            notify temperature -i "display" " Reset"
          ;;
          "") error "Expected an Option" "Try 'hyprutils help' for more information" ;;
          *) error "Unexpected Option 'temperature $2'" "Try 'hyprutils help' for more information" ;;
          esac
        ;;
        "volume")
          volume_notification() {
            volume=$(amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1)
            mute=$(amixer get Master | grep '%' | grep -oE '[^ ]+$' | grep off | head -n1)
            if [ "$volume" -eq 0 ] || [ "$mute" == "[off]" ]
            then
              volume_icon=""
            else
              volume_icon=""
            fi

            song_title=$(playerctl -f "{{title}}" metadata)
            get_media_icon
            if $show_music_in_volume_indicator && [ -n "$song_title" ]
            then
              song_artist=$(playerctl -f "{{artist}}" metadata)
              if [ -z "$song_artist" ]
              then
                notify volume -h int:value:"$volume" -i "$media_icon" "$volume_icon $volume%" "$song_title"
              else
                notify volume -h int:value:"$volume" -i "$media_icon" "$volume_icon $volume%" "$song_title\nBy $song_artist"
              fi
            else
              notify volume -h int:value:"$volume" -i "$media_icon" "$volume_icon $volume%"
            fi
          }
          case "$2" in
          "up")
            amixer set Master on
            amixer sset Master 5%+
            volume_notification
          ;;
          "down")
            amixer set Master on
            amixer sset Master 5%-
            volume_notification
          ;;
          "mute")
            amixer set Master 1+ toggle
            volume_notification
          ;;
          "") error "Expected an Option" "Try 'hyprutils help' for more information" ;;
          *) error "Unexpected Option 'volume $2'" "Try 'hyprutils help' for more information" ;;
          esac
        ;;
        "media")
          music_notification() {
            song_title=$(playerctl -f "{{title}}" metadata)
            song_artist=$(playerctl -f "{{artist}}" metadata)
            song_album=$(playerctl -f "{{album}}" metadata)
            get_media_icon
            if [ -z "$song_album" ]
            then
              if [ -z "$song_artist" ]
              then
                notify music -i "$media_icon" "$song_title"
              else
                notify music -i "$media_icon" "$song_title" "By $song_artist"
              fi
            else
              notify music -i "$media_icon" "$song_title" "By $song_artist from $song_album"
            fi
          }
          case "$2" in
          "next")
            playerctl next
            sleep 0.5 && music_notification
          ;;
          "previous")
            playerctl previous
            sleep 0.5 && music_notification
          ;;
          "toggle")
            playerctl play-pause
            music_notification
          ;;
          "") error "Expected an Option" "Try 'hyprutils help' for more information" ;;
          *) error "Unexpected Option 'media $2'" "Try 'hyprutils help' for more information" ;;
          esac
        ;;
        "zoom")
          ZOOM=$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2}')
          case "$2" in
          "in")
            ZOOM=$(echo "$ZOOM" | awk '{print $1 + 0.2}')
            hyprctl keyword cursor:zoom_factor "$ZOOM"
            hyprctl notify 1 1000 0 "Zoomed In ($ZOOM""x)"
          ;;
          "out")
            if [ "$ZOOM" = "1.000000" ]
            then
              hyprctl notify 3 2000 0 "Already zoomed out"
            else
              ZOOM=$(echo "$ZOOM" | awk '{print $1 - 0.2}')
              hyprctl keyword cursor:zoom_factor "$ZOOM"
              hyprctl notify 1 1000 0 "Zoomed Out ($ZOOM""x)"
            fi
          ;;
          "") error "Expected an Option" "Try 'hyprutils help' for more information" ;;
          *) error "Unexpected Option 'zoom $2'" "Try 'hyprutils help' for more information" ;;
          esac
        ;;
        "toggle")
          case "$2" in
          "fancy")
            FANCY=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
            if [ "$FANCY" = 1 ]
            then
              hyprctl notify 1 2000 0 "Compositor Effects Disabled"
              hyprctl --batch "\
                keyword animations:enabled 0;\
                keyword decoration:shadow:enabled 0;\
                keyword decoration:blur:enabled 0;\
                keyword general:gaps_in 0;\
                keyword general:gaps_out 0;\
                keyword general:border_size 1;\
                keyword decoration:rounding 0"
              exit
            fi
            hyprctl notify 1 2000 0 "Compositor Effects Enabled"
            hyprctl reload
          ;;
          "float")
            WORKSPACE=$(hyprctl activeworkspace | grep "workspace ID" | awk '{print $3}')
            hyprctl notify 1 2000 0 "Toggled window floating on Workspace $WORKSPACE"
            hyprctl dispatch workspaceopt allfloat
          ;;
          "minimized")
            if hyprctl workspaces | grep "special:minimize"
            then
              hyprctl dispatch workspace special:minimized
            else
              hyprctl notify 1 2000 0 "No minimized windows present"
            fi
          ;;
          "monitor")
            if hyprctl monitors | grep "$3"
            then
              hyprctl keyword monitor "$3, disable"
            else
              hyprctl keyword monitor "$3, preferred, auto, 1"
            fi
          ;;
          "service")
            if [ -z "$3" ]
            then
              error "Expected service name" "Try 'hyprutils help' for more information"
            fi

            if systemctl --user is-active "$3"
            then
              systemctl --user stop "$3"
              notify service -i "system-config-services" "Stopped $3"
            else
              systemctl --user start "$3"
              notify service -i "system-config-services" "Started $3"
            fi
          ;;
          "shader")
            hyprshade off
            mapfile SHADERS < <(hyprshade ls)
            SHADER=$(zenity --list --title="Compositor Shader Toggle" --column="Shaders" "''${SHADERS[@]}" | sed "s/^[ \t]*//")
            hyprshade on "$SHADER" && hyprctl seterror ""
          ;;
          "touchpad")
            temp touchpad 1
            STATUS="$TEMP/status"
            touchpad=$(hyprctl devices | grep touchpad | xargs)

            enable() {
              hyprctl keyword "device[$touchpad]:enabled" true
              printf "true" >"$STATUS"
              notify touchpad -i "touchpad" "Touchpad Enabled"
            }

            disable() {
              hyprctl keyword "device[$touchpad]:enabled" false
              printf "false" >"$STATUS"
              notify touchpad -i "touchpad" "Touchpad Disabled"
            }

            if ! [ -f "$STATUS" ]
            then
              disable
            else
              if [ "$(cat "$STATUS")" = "true" ]
              then
                disable
              elif [ "$(cat "$STATUS")" = "false" ]
              then
                enable
              fi
            fi
          ;;
          "") error "Expected an Option" "Try 'hyprutils help' for more information" ;;
          *) error "Unexpected Option 'toggle $2'" "Try 'hyprutils help' for more information" ;;
          esac
        ;;
      esac
    '';
  })
