{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  inherit (config.shared) enable theme;
  inherit (theme) icons;
  inherit (config.lib.stylix) colors;
in
{
  ## Notifications Configuration
  config = mkIf enable {
    # Phone Connect
    user.persist.directories = [ ".config/kdeconnect" ];
    programs.kdeconnect.enable = true;
    user.homeConfig = {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };

      # Notifications Daemon
      stylix.targets.dunst.enable = true;
      services.dunst =
        let
          system = {
            fullscreen = "show";
            highlight = "#${colors.base07}";
            history_ignore = "yes";
            override_pause_level = 70;
          };
        in
        {
          enable = true;
          iconTheme = icons;
          settings = {
            global = {
              alignment = "center";
              corner_radius = 10;
              follow = "mouse";
              format = "<b>%s</b>\\n%b";
              frame_width = 1;
              horizontal_padding = 8;
              icon_corner_radius = 10;
              icon_position = "left";
              icon_theme = icons.name;
              indicate_hidden = "yes";
              markup = "yes";
              max_icon_size = 64;
              mouse_left_click = "do_action";
              mouse_middle_click = "close_all";
              mouse_right_click = "close_current";
              offset = "10x5";
              padding = 8;
              progress_bar_corner_radius = 10;
              separator_height = 1;
              show_indicators = false;
              shrink = "no";
              transparency = 10;
              word_wrap = "yes";
            };

            urgency_low.frame_color = mkForce "#${colors.base0E}";
            urgency_normal.frame_color = mkForce "#${colors.base0D}";
            fullscreen_delay.fullscreen = "delay";
            utility = {
              appname = "utility";
            }
            // system;
            upower = {
              appname = "poweralertd";
              new_icon = "/run/current-system/sw/share/icons/${icons.name}/24x24/apps/preferences-system-power.svg";
            }
            // system;

            hyprland = {
              appname = "grimblast";
            }
            // system;
            niri = {
              appname = "niri";
            }
            // system;
          };
        };
    };
  };
}
