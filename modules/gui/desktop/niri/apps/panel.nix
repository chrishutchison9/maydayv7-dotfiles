{
  config,
  pkgs,
  files,
  ...
}:
let
  inherit (config.gui) display;
in
{
  ## Panel Configuration
  user.homeConfig.programs.waybar = {
    style = files.niri.waybar;

    # Panel
    settings =
      let
        shared = {
          layer = "top";
          position = "left";

          width = 30;
          spacing = 3;
          margin-top = 5;
          margin-right = 0;
          margin-bottom = 5;
          margin-left = 3;

          "custom/logo" = {
            format = "󱄅";
            tooltip = false;
            on-click = "nwg-drawer";
          };

          "group/users" = {
            orientation = "vertical";
            modules = [
              "user"
              "custom/power"
            ];
            drawer.transition-left-to-right = false;
          };

          user = {
            format = "{user}";
            icon = false;
            open-on-click = true;
          };

          "custom/power" = {
            format = "⏻";
            tooltip = false;
            on-click = "wlogout -p layer-shell";
          };

          "niri/workspaces" = {
            all-outputs = false;
            format = "<small>{value}</small>";
          };

          "niri/window" = {
            format = "";
            icon = true;
            icon-size = 24;
            separate-outputs = true;
          };

          "group/menu" = {
            orientation = "vertical";
            modules = [
              "custom/hide"
              "tray"
              "keyboard-state"
            ];
            drawer = {
              click-to-reveal = true;
              transition-left-to-right = false;
            };
          };

          "custom/hide" = {
            format = "";
            tooltip = false;
          };

          tray.icon-size = 14;
          keyboard-state = {
            numlock = true;
            capslock = true;
            format = {
              numlock = " N\n{icon}";
              capslock = "󰪛\n{icon}";
            };
            format-icons = {
              locked = "";
              unlocked = "";
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

          network =
            let
              tooltip = "Strength: <b>{signaldBm}dBm ({signalStrength}%)</b>\nFrequency: <b>{frequency}MHz</b>\nInterface: <b>{ifname}</b>\nIP: <b>{ipaddr}/{cidr}</b>\nGateway: <b>{gwaddr}</b>\nNetmask: <b>{netmask}</b>";
            in
            {
              format = "{ifname}";
              format-disconnected = "󰌙";
              format-wifi = "{icon}";
              format-ethernet = "󰌘";
              format-icons = [
                "󰤯"
                "󰤟"
                "󰤢"
                "󰤥"
                "󰤨"
              ];
              format-linked = "󰈁 {ifname}";
              tooltip-format-wifi = "Network: <big><b>{essid}</b></big>\n${tooltip}";
              tooltip-format-ethernet = "Network: <big><b>Wired</b></big>\n${tooltip}";
              tooltip-format-disconnected = "󰌙 Disconnected";
              on-click = "sh -c 'env XDG_CURRENT_DESKTOP=GNOME gnome-control-center wifi'";
            };

          "group/media" = {
            orientation = "vertical";
            modules = [
              "wireplumber"
              "mpris"
            ];
            drawer = {
              transition-left-to-right = true;
              transition-duration = 1000;
            };
          };

          wireplumber = {
            max-volume = 150;
            scroll-step = 1;
            reverse-scrolling = 1;
            format = "{icon}";
            tooltip-format = "Volume: {volume}%\nDevice: {node_name}";
            format-icons = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            format-muted = "";
            on-click = "pavucontrol";
          };

          mpris = {
            dynamic-len = 20;
            dynamic-order = [
              "title"
              "artist"
              "length"
            ];
            dynamic-separator = " - ";
            format = "";
            format-paused = "󰏤";
            format-stopped = "";
            tooltip-format-stopped = "Not Playing";
            on-click = "sysutils media toggle";
            on-click-right = "sysutils media next";
            on-click-middle = "sysutils media previous";
          };

          backlight = {
            format = "{icon}";
            tooltip-format = "Backlight: {percent}%";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
            on-scroll-up = "sysutils brightness down";
            on-scroll-down = "sysutils brightness up";
          };

          "group/power" = {
            orientation = "vertical";
            modules = [
              "battery"
              "power-profiles-daemon"
            ];
            drawer.transition-left-to-right = true;
          };

          battery = {
            interval = 5;
            format = "{icon}";
            tooltip-format = "Battery: {capacity}%";
            format-charging = "";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
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
              performance = "󱄟";
              balanced = "";
              power-saver = "";
            };
          };

          "custom/weather" = {
            format = "{}";
            return-type = "json";
            exec = "wttrbar --date-format %d/%m --nerd --vertical-view";
            tooltip = true;
            interval = 600;
            signal = 7;
            on-click = "pkill -RTMIN+7 waybar";
          };

          clock = {
            interval = 1;
            format = "󰅐\n{:%H\n%M\n%S} ";
            format-alt = "󰅐\n{:%I\n%M\n\n%d\n%m\n%y} ";
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
            orientation = "vertical";
            modules = [
              "custom/dunst"
              "idle_inhibitor"
            ];
            drawer.transition-left-to-right = true;
          };

          "custom/dunst" =
            let
              run =
                text:
                "${
                  pkgs.writeShellApplication {
                    name = "notify";
                    inherit text;
                    runtimeInputs = with pkgs; [
                      coreutils
                      dunst
                    ];
                  }
                }/bin/notify";
            in
            {
              tooltip = false;
              on-click = "dunstctl history-pop";
              restart-interval = 1;
              on-click-right = run ''
                if dunstctl is-paused | grep -q "false"
                then
                  dunstctl set-pause-level 50
                else
                  dunstctl set-pause-level 0
                fi
              '';
              exec = run ''
                COUNT=$(dunstctl count waiting)
                ENABLED=""
                DISABLED=""
                if [ "$COUNT" != 0 ]; then DISABLED="\n$COUNT"; fi
                if dunstctl is-paused | grep -q "false"; then echo "$ENABLED"; else echo "$DISABLED"; fi
              '';
            };

          idle_inhibitor = {
            format = "{icon}";
            on-click = "sysutils toggle service swayidle";
            tooltip-format-activated = "Idle Inhibitor: On";
            tooltip-format-deactivated = "Idle Inhibitor: Off";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          modules-right = [
            "group/menu"
            "group/users"
            "custom/logo"
          ];

          modules-center = [
            "niri/window"
            "niri/workspaces"
          ];
        };
      in
      [
        (
          shared
          // {
            output = display;
            modules-left = [
              "group/notify"
              "clock"
              "custom/weather"
              "group/power"
              "backlight"
              "group/media"
              "network"
              "bluetooth"
            ];
          }
        )
        (
          shared
          // {
            output = "!" + display;
            modules-left = [
              "group/notify"
              "clock"
              "group/power"
              "group/media"
              "network"
              "bluetooth"
            ];
          }
        )
      ];
  };
}
