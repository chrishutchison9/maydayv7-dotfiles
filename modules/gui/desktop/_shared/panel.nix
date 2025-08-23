{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
in
{
  ## Panel Configuration
  options._shared.panel = mkOption {
    description = "INTERNAL: Shared Panel Configuration";
    type = types.attrs;
  };

  config = mkIf config._shared.enable {
    user.homeConfig = {
      stylix.targets.waybar = {
        enable = true;
        font = "sansSerif";
        addCss = false;
      };

      home.packages = [ pkgs.wttrbar ];
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        package = pkgs.unstable.waybar;
      };
    };

    _shared.panel = {
      layer = "top";

      "custom/logo" = {
        format = "󱄅";
        tooltip = false;
        on-click = "nwg-drawer";
      };

      user = {
        format = "{user}";
        icon = true;
        height = 30;
        width = 30;
        open-on-click = true;
      };

      "custom/user" = {
        exec = "sh -c 'getent passwd $USER | cut -d : -f 5'";
        format = "{}";
        rotate = 270;
        tooltip = false;
        on-click = "sh -c 'nemo ~'";
      };

      "custom/power" = {
        format = "⏻";
        tooltip = false;
        on-click = "wlogout -p layer-shell";
      };

      "group/menu" = {
        modules = [
          "custom/hide"
          "keyboard-state"
          "tray"
        ];
        drawer.click-to-reveal = true;
      };

      "custom/hide" = {
        format = mkDefault "";
        tooltip = false;
      };

      keyboard-state = {
        numlock = true;
        capslock = true;
        format = {
          numlock = mkDefault " N {icon}";
          capslock = mkDefault "󰪛 {icon}";
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
          format = mkDefault "? {ifname}";
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
          format-linked = mkDefault "󰈁 {ifname}";
          tooltip-format-wifi = "Network: <big><b>{essid}</b></big>\n${tooltip}";
          tooltip-format-ethernet = "Network: <big><b>Wired</b></big>\n${tooltip}";
          tooltip-format-disconnected = "󰌙 Disconnected";
          on-click = "sh -c 'env XDG_CURRENT_DESKTOP=GNOME gnome-control-center wifi'";
        };

      "group/media" = {
        modules = [
          "wireplumber"
          "mpris"
        ];
        drawer.transition-duration = 1000;
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
        format = mkDefault " {player}";
        format-paused = mkDefault "󰏤 <i>{player}</i>";
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

      "group/power".modules = [
        "battery"
        "power-profiles-daemon"
      ];

      battery = {
        interval = 5;
        rotate = 0;
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
        format = mkDefault "{}°";
        return-type = "json";
        exec = mkDefault "wttrbar --date-format %d/%m --nerd";
        tooltip = true;
        interval = 600;
        signal = 7;
        on-click = "pkill -RTMIN+7 waybar";
      };

      clock = {
        interval = 1;
        format = mkDefault "󰅐 {:%H:%M:%S} ";
        format-alt = mkDefault "󰅐 {:%I:%M    %A, %d %B %Y} ";
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

      "group/notify".modules = [
        "custom/dunst"
        "idle_inhibitor"
      ];

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
            if [ "$COUNT" != 0 ]; then DISABLED=" $COUNT"; fi
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
    };
  };
}
