{
  config,
  theme,
  ...
}: {
  ## Notifications Configuration
  # Phone Connect
  user.persist.directories = [".config/kdeconnect"];
  programs.kdeconnect.enable = true;
  user.homeConfig = {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    # Alerts
    services.poweralertd.enable = true;

    # Notifications Daemon
    stylix.targets.dunst.enable = true;
    services.dunst = let
      ignore = {
        history_ignore = "yes";
        fullscreen = "show";
        highlight = "#${config.lib.stylix.colors.base07}";
      };
    in {
      enable = true;
      iconTheme = theme.icons;
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
          icon_theme = theme.icons.name;
          indicate_hidden = "yes";
          markup = "yes";
          max_icon_size = 64;
          mouse_left_click = "do_action";
          mouse_middle_click = "close_all";
          mouse_right_click = "close_current";
          offset = "5x5";
          padding = 8;
          progress_bar_corner_radius = 10;
          separator_height = 1;
          show_indicators = false;
          shrink = "no";
          transparency = 10;
          word_wrap = "yes";
        };

        fullscreen_delay.fullscreen = "delay";
        utility = {appname = "utility";} // ignore;
        upower =
          {
            appname = "poweralertd";
            new_icon = "/run/current-system/sw/share/icons/${theme.icons.name}/24x24/apps/preferences-system-power.svg";
          }
          // ignore;
      };
    };
  };
}
