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
      backlight [up,down]            - Keyboard Backlight Controls
      toggle 
        float                        - Toggle window floating in current workspace
        minimized                    - Show minimized windows
        monitor 'name'               - Toggle specified Monitor
        shader                       - Toggle Compositor Shader
        touchpad                     - Toggle touchpad
        service 'name'               - Toggle SYSTEMD Service
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
  recursiveUpdate
  {
    meta = {
      mainProgram = "hyprutils";
      description = "Hyprland Utility Script";
      homepage = files.path.repo;
      license = licenses.gpl3Only;
      maintainers = ["maydayv7"];
    };
  }
  (
    pkgs.writeShellApplication {
      name = "hyprutils";
      runtimeInputs = with pkgs; [
        coreutils
        gnugrep
        socat

        brightnessctl
        custom.hyprshellevents
        hyprland
        hyprshade
        systemd
        zenity
      ];

      text = ''
        set +eu
        ${files.scripts.commands}

        hyprnotify() {
          hyprctl notify "$1" 1500 0 "  $2  "
        }

        fail() {
          error "$1" "Try 'hyprutils help' for more information"
        }

        case "$1" in
          "") error "Expected an Option" "${help}";;
          "help") echo -e "## Hyprland Utility Script ##\n${help}";;
          "daemon")
            info "Monitoring Hyprland Socket..."
            socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock EXEC:"shellevents ${daemon}",nofork
          ;;
          "backlight")
            case "$2" in
            "up") brightnessctl -d "*::kbd_backlight" set 33%+ ;;
            "down") brightnessctl -d "*::kbd_backlight" set 33%- ;;
            "") fail "Expected an Option" ;;
            *) fail "Unexpected Option 'backlight $2'" ;;
            esac
          ;;
          "toggle")
            case "$2" in
            "float")
              WORKSPACE=$(hyprctl activeworkspace | grep "workspace ID" | awk '{print $3}')
              hyprnotify 1 "Toggled window floating on Workspace $WORKSPACE"
              hyprctl dispatch workspaceopt allfloat
            ;;
            "minimized")
              if hyprctl workspaces | grep "special:minimize"
              then
                hyprctl dispatch workspace special:minimized
              else
                hyprnotify 1 "No minimized windows present"
              fi
            ;;
            "monitor")
              if [ -z "$3" ]
              then
                fail "Expected monitor name"
              fi

              if hyprctl monitors | grep "Monitor $3"
              then
                hyprctl keyword monitor "$3, disable"
              else
                hyprctl keyword monitor "$3, preferred, auto, 1"
              fi
              hyprctl reload
            ;;
            "shader")
              hyprshade off
              mapfile SHADERS < <(hyprshade ls)
              SHADER=$(zenity --list --title="Compositor Shader Toggle" --column="Shaders" "''${SHADERS[@]}" | sed "s/^[ \t]*//")
              hyprshade on "$SHADER" && hyprctl seterror ""
            ;;
            "touchpad")
              temp hyprutils_touchpad 1
              STATUS="$TEMP/status"
              touchpad=$(hyprctl devices | grep touchpad | xargs)

              enable() {
                hyprctl keyword "device[$touchpad]:enabled" true
                printf "true" >"$STATUS"
                hyprnotify 1 "Touchpad Enabled"
              }

              disable() {
                hyprctl keyword "device[$touchpad]:enabled" false
                printf "false" >"$STATUS"
                hyprnotify 1 "Touchpad Disabled"
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
            "service")
              if [ -z "$3" ]
              then
                fail "Expected service name"
              fi

              if systemctl --user is-active "$3"
              then
                systemctl --user stop "$3"
                hyprnotify 1 "Stopped $3"
              else
                systemctl --user start "$3"
                hyprnotify 1 "Started $3"
              fi
            ;;
            "") fail "Expected an Option" ;;
            *) fail "Unexpected Option 'toggle $2'" ;;
            esac
          ;;
          *) fail "Unexpected Option '$1'" ;;
        esac
      '';
    }
  )
