# Noctalia Shell
{inputs ? null, ...}: {
  home = {
    config,
    osConfig ? null,
    ...
  }: let
    inherit (config.lib.stylix.colors) withHashtag;
    inherit (config.stylix.fonts) sansSerif;
  in {
    imports = [inputs.noctalia.homeModules.default];
    stylix.targets.noctalia-shell.enable = false;
    home.persist.directories = [
      ".cache/noctalia"
      ".local/share/noctalia"
      ".local/state/noctalia"
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        shell = {
          font_family = sansSerif.name;
          clipboard_enabled = true;
          clipboard_history_max_entries = 150;
          polkit_agent = true;
        };

        theme = {
          source = "custom";
          custom_palette = "stylix";
          mode = "dark";
        };

        # Bar
        bar.main = {
          position = "top";
          start = ["session" "control-center" "workspaces"];
          center = ["launcher" "clock" "media"];
          end = [
            "tray"
            "system_monitor"
            "clipboard"
            "bluetooth"
            "network"
            "volume"
            "brightness"
            "battery"
            "notifications"
          ];
        };

        # Notifications
        notification.enable_daemon = true;
        osd.kinds = {
          volume = true;
          brightness = true;
          wifi = true;
          bluetooth = true;
          power_profile = true;
          caffeine = true;
          dnd = true;
          keyboard_layout = true;
        };

        # Wallpaper
        wallpaper = {
          enabled = true;
          fill_mode = "crop";
          default.path = "${osConfig.stylix.image}";
        };

        # Lock Screen
        lockscreen = {
          enabled = true;
          blurred_desktop = true;
          blur_intensity = 0.5;
        };

        # Screen Idle
        idle.behavior = {
          lock = {
            enabled = true;
            timeout = 300;
            command = "noctalia:session lock";
          };
          "screen-off" = {
            enabled = true;
            timeout = 360;
            command = "noctalia:dpms-off";
            resume_command = "noctalia:dpms-on";
          };
        };

        # Screenshots
        shell.screenshot = {
          save_to_file = true;
          copy_to_clipboard = true;
          freeze_screen = true;
          directory = "~/Pictures/Screenshots";
        };

        # Night Light
        nightlight = {
          enabled = true;
          temperature_day = 6500;
          temperature_night = 4000;
        };

        location = {
          auto_locate = true;
          sunset = "19:00";
          sunrise = "06:00";
        };

        brightness.enable_ddcutil = false;
        system.monitor.enabled = true;
        weather.enabled = true;
      };

      # Color Palette
      customPalettes.stylix.dark = with withHashtag; {
        primary = base0D;
        onPrimary = base00;
        secondary = base0E;
        onSecondary = base00;
        tertiary = base0C;
        onTertiary = base00;
        error = base08;
        onError = base00;
        surface = base00;
        onSurface = base05;
        surfaceVariant = base01;
        onSurfaceVariant = base04;
        outline = base03;
        shadow = base00;
        hover = base0C;
        onHover = base00;
        terminal = with withHashtag; {
          normal = {
            black = base00;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
            white = base05;
          };
          bright = {
            black = base03;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
            white = base07;
          };
          foreground = base05;
          background = base00;
          cursor = base05;
          cursorText = base00;
          selectionFg = base05;
          selectionBg = base02;
        };
      };
    };
  };
}
