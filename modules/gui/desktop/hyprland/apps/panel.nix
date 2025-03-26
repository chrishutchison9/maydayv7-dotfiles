{
  config,
  pkgs,
  files,
  ...
}: {
  ## Panel Configuration
  user.homeConfig = {
    stylix.targets.waybar = {
      enable = true;
      font = "sansSerif";
      enableCenterBackColors = true;
      enableLeftBackColors = true;
      enableRightBackColors = true;
    };

    home.packages = [pkgs.wttrbar];
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      package = pkgs.waybar;
      style = files.hyprland.waybar;

      # Panel
      settings = [
        {
          layer = "top";
          position = "top";

          height = 30;
          spacing = 3;
          margin-top = 3;
          margin-right = 5;
          margin-bottom = 5;
          margin-left = 5;

          modules-left = [
            "custom/logo"
            "group/users"
            "hyprland/workspaces"
            "custom/minimize"
          ];

          modules-center = [
            "hyprland/window"
            "hyprland/submap"
          ];

          modules-right = [
            "group/menu"
            "bluetooth"
            "network"
            "group/media"
            "group/display"
            "group/power"
            "custom/weather"
            "clock"
            "group/notify"
          ];

          "custom/logo" = {
            format = "";
            tooltip = false;
            on-click = "nwg-drawer";
          };

          "group/users" = {
            orientation = "horizontal";
            modules = ["user" "custom/power"];
            drawer.transition-left-to-right = true;
          };

          user = {
            format = "{user}";
            icon = true;
            height = 30;
            width = 30;
            open-on-click = true;
          };

          "custom/power" = {
            format = "";
            tooltip = false;
            on-click = "wlogout -p layer-shell";
          };

          "hyprland/workspaces" = {
            all-outputs = true;
            show-special = true;
            format = "<small>{name}</small>{icon}";
            on-scroll-up = "hyprctl dispatch workspace m+1";
            on-scroll-down = "hyprctl dispatch workspace m-1";
            ignore-workspaces = ["special:scratch_.*" "special:minimize"];
            format-icons = {
              default = "";
              special = " ";
              "1" = " ";
              "2" = " ";
              "3" = " ";
              "4" = " ";
              "5" = " ";
              "6" = " ";
              "7" = " ";
              "8" = " ";
              "9" = " ";
            };
          };

          "custom/minimize" = {
            format = "";
            on-click = "hyprutils toggle minimize";
          };

          "hyprland/submap" = {
            always-on = false;
            tooltip = false;
            format = " {}";
            on-click = "hyprctl dispatch submap reset";
          };

          "hyprland/window" = {
            format = "";
            icon = true;
            separate-outputs = true;
          };

          "group/menu" = {
            orientation = "horizontal";
            modules = ["custom/hide" "keyboard-state" "tray"];
            drawer = {
              click-to-reveal = true;
              transition-left-to-right = true;
            };
          };

          "custom/hide" = {
            format = "";
            tooltip = false;
          };

          tray.icon-size = 14;
          keyboard-state = {
            numlock = true;
            capslock = true;
            format = {
              numlock = " N {icon}";
              capslock = "󰪛 {icon}";
            };
            format-icons = {
              locked = "";
              unlocked = "";
            };
          };

          bluetooth = {
            format = "";
            format-disabled = "󰂳";
            format-connected = "󰂱 {num_connections}";
            tooltip-format = " {status}";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = " {device_alias} 󰂄 {device_battery_percentage}%";
            on-click = "overskride";
          };

          network = let
            tooltip = "Strength: <b>{signaldBm}dBm ({signalStrength}%)</b>\nFrequency: <b>{frequency}MHz</b>\nInterface: <b>{ifname}</b>\nIP: <b>{ipaddr}/{cidr}</b>\nGateway: <b>{gwaddr}</b>\nNetmask: <b>{netmask}</b>";
          in {
            format = "{ifname}";
            format-disconnected = "󰌙";
            format-wifi = "{icon}";
            format-ethernet = "󰌘";
            format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            format-linked = "󰈁 {ifname}";
            tooltip-format-wifi = "Network: <big><b>{essid}</b></big>\n${tooltip}";
            tooltip-format-ethernet = "Network: <big><b>Wired</b></big>\n${tooltip}";
            tooltip-format-disconnected = "󰌙 Disconnected";
            on-click = "sh -c 'env XDG_CURRENT_DESKTOP=GNOME gnome-control-center wifi'";
          };

          "group/media" = {
            orientation = "horizontal";
            modules = ["wireplumber" "mpris"];
            drawer = {
              transition-left-to-right = false;
              transition-duration = 1000;
            };
          };

          wireplumber = {
            max-volume = 150;
            scroll-step = 1;
            reverse-scrolling = 1;
            format = "{icon}";
            tooltip-format = "Volume: {volume}%\nDevice: {node_name}";
            format-muted = "";
            format-icons = ["" "" "󰕾" ""];
            on-click = "pavucontrol";
          };

          mpris = {
            dynamic-len = 20;
            dynamic-order = ["title" "artist" "length"];
            dynamic-separator = " - ";
            format = " {player} - {dynamic}";
            format-paused = "󰏤 <i>{player}</i>";
            format-stopped = "";
            tooltip-format-stopped = "Not Playing";
            on-click = "hyprutils media toggle";
            on-click-right = "hyprutils media next";
            on-click-middle = "hyprutils media previous";
          };

          "group/display" = {
            orientation = "horizontal";
            modules = ["backlight" "custom/temperature"];
            drawer.transition-left-to-right = false;
          };

          backlight = {
            format = "{icon}";
            tooltip-format = "Backlight: {percent}%";
            format-icons = ["" "" "" "" "" "" "" "" ""];
            on-scroll-up = "hyprutils brightness down";
            on-scroll-down = "hyprutils brightness up";
            on-click = "nwg-displays";
          };

          "custom/temperature" = {
            format = "";
            tooltip = false;
            on-scroll-up = "hyprutils temperature up";
            on-scroll-down = "hyprutils temperature down";
            on-click = "hyprutils temperature reset";
          };

          "group/power" = {
            orientation = "horizontal";
            modules = ["battery" "power-profiles-daemon"];
            drawer.transition-left-to-right = false;
          };

          battery = {
            interval = 5;
            align = 0;
            rotate = 0;
            format = "{icon}";
            tooltip-format = "Battery: {capacity}%";
            format-charging = "";
            format-icons = ["" "" "" "" ""];
            on-click-right = "hyprutils toggle fancy";
            states = {
              good = 80;
              warning = 20;
              critical = 10;
            };
          };

          power-profiles-daemon = {
            format = "{icon}";
            tooltip = true;
            tooltip-format = "Power Profile: {profile}";
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };

          "custom/weather" = {
            format = "{}°";
            tooltip = true;
            interval = 3600;
            exec = "wttrbar --date-format %d/%m --nerd";
            return-type = "json";
          };

          clock = {
            interval = 1;
            format = " {:%H:%M:%S} ";
            format-alt = " {:%I:%M   %A, %d %B %Y} ";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "left";
              on-scroll = 1;
              format = with config.lib.stylix.colors; {
                months = "<span color='#${base06}'><b>{}</b></span>";
                days = "<span color='#${base05}'><b>{}</b></span>";
                weeks = "<span color='#${base0C}'><b>W{}</b></span>";
                weekdays = "<span color='#${base0A}'><b>{}</b></span>";
                today = "<span color='#${base08}'><b><u>{}</u></b></span>";
              };
            };

            actions = {
              on-click-right = "mode";
              on-click-forward = "tz_up";
              on-click-backward = "tz_down";
              on-scroll-up = "shift_down";
              on-scroll-down = "shift_up";
            };
          };

          "group/notify" = {
            orientation = "horizontal";
            modules = ["custom/dunst" "idle_inhibitor"];
            drawer.transition-left-to-right = false;
          };

          "custom/dunst" = {
            tooltip = false;
            on-click = "dunstctl history-pop";
            on-click-right = "dunstctl set-paused toggle";
            restart-interval = 1;
            exec = with pkgs; "${writeShellApplication {
              name = "notify";
              runtimeInputs = [coreutils dunst];
              text = ''
                COUNT=$(dunstctl count waiting)
                ENABLED=""
                DISABLED=""
                if [ "$COUNT" != 0 ]; then DISABLED=" $COUNT"; fi
                if dunstctl is-paused | grep -q "false" ; then echo "$ENABLED"; else echo "$DISABLED"; fi
              '';
            }}/bin/notify";
          };

          idle_inhibitor = {
            format = "{icon}";
            on-click = "hyprutils toggle service swayidle";
            tooltip-format-activated = "Idle Inhibitor: On";
            tooltip-format-deactivated = "Idle Inhibitor: Off";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };
        }
      ];
    };
  };
}
