{
  config,
  lib,
  files,
  ...
}:
let
  inherit (lib) mkMerge;
  inherit (config._shared) panel theme;
  inherit (config.gui) display;
in
{
  ## Panel Configuration
  user.homeConfig.programs.waybar = {
    style = files.hyprland.waybar;
    settings =
      let
        shared = {
          position = "top";
          height = 40;
          spacing = 3;
          margin-top = 2;
          margin-right = 5;
          margin-bottom = 1;
          margin-left = 5;

          "group/users" = {
            orientation = "horizontal";
            modules = [
              "user"
              "custom/power"
            ];
            drawer.transition-left-to-right = true;
          };

          user = {
            height = 20;
            width = 20;
          };

          "hyprland/workspaces" = {
            all-outputs = false;
            show-special = true;
            format = "<small>{name}</small>{icon}";
            on-scroll-up = "hyprctl dispatch workspace m+1";
            on-scroll-down = "hyprctl dispatch workspace m-1";
            ignore-workspaces = [
              "special:scratch_.*"
              "special:minimized"
            ];
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

          "hyprland/submap" = {
            always-on = false;
            tooltip = false;
            format = " {}";
            on-click = "hyprctl dispatch submap reset";
          };

          "hyprland/window" = {
            format = "{class}";
            icon = false;
            separate-outputs = true;
          };

          "wlr/taskbar" = {
            format = "{icon}";
            icon-size = 20;
            all-outputs = false;
            active-first = false;
            icon-theme = theme.icons.name;
            markup = true;
            tooltip-format = "Name: <big><b>{name}</b></big> <i>{short_state}</i>\nTitle: <b>{title}</b>";
            on-click = "activate";
            on-click-middle = "minimize";
            on-click-right = "close";
            ignore-list = [
              "kitty-clip"
              "kitty-dropterm"
            ];
          };

          "custom/minimized" = {
            format = "";
            on-click = "hyprutils toggle minimized";
          };

          "group/menu" = {
            orientation = "horizontal";
            drawer.transition-left-to-right = true;
          };

          "group/media" = {
            orientation = "horizontal";
            drawer.transition-left-to-right = false;
          };

          "group/display" = {
            orientation = "horizontal";
            modules = [
              "backlight"
              "custom/temperature"
            ];
            drawer.transition-left-to-right = false;
          };

          backlight.on-click = "nwg-displays";

          "custom/temperature" = {
            format = "";
            tooltip = false;
            on-scroll-up = "hyprutils temperature up";
            on-scroll-down = "hyprutils temperature down";
            on-click = "hyprutils temperature reset";
          };

          "group/power" = {
            orientation = "horizontal";
            drawer.transition-left-to-right = false;
          };

          battery = {
            align = 0;
            on-click-right = "hyprutils toggle fancy";
          };

          "group/notify" = {
            orientation = "horizontal";
            drawer.transition-left-to-right = false;
          };

          modules-left = [
            "custom/logo"
            "group/users"
            "hyprland/workspaces"
            "hyprland/submap"
            "hyprland/window"
          ];

          modules-center = [
            "wlr/taskbar"
            "custom/minimized"
          ];
        };
      in
      [
        (mkMerge [
          panel
          shared
          {
            output = display;
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
          }
        ])
        (mkMerge [
          panel
          shared
          {
            output = "!" + display;
            modules-right = [
              "group/menu"
              "bluetooth"
              "network"
              "group/media"
              "group/power"
              "custom/weather"
              "clock"
              "group/notify"
            ];
          }
        ])
      ];
  };
}
