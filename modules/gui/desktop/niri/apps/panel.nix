{
  config,
  lib,
  files,
  ...
}:
let
  inherit (lib) mkMerge;
  inherit (config._shared) panel;
  inherit (config.gui) display;
in
{
  ## Panel Configuration
  user.homeConfig.programs.waybar = {
    style = files.niri.waybar;
    settings =
      let
        shared = {
          position = "left";
          width = 40;
          spacing = 3;
          margin = "0";

          "group/users" = {
            orientation = "vertical";
            modules = [
              "custom/user"
              "custom/power"
            ];
            drawer.transition-left-to-right = false;
          };

          "niri/workspaces" = {
            all-outputs = false;
            format = "<small>{value}</small>";
          };

          "niri/window" = {
            format = "";
            icon = true;
            icon-size = 20;
            separate-outputs = true;
          };

          "group/menu" = {
            orientation = "vertical";
            drawer.transition-left-to-right = false;
          };

          keyboard-state.format = {
            numlock = " N\n{icon}";
            capslock = "󰪛\n{icon}";
          };

          network = {
            format = "?";
            format-linked = "󰈁";
          };

          "group/media" = {
            orientation = "vertical";
            drawer.transition-left-to-right = true;
          };

          mpris = {
            format = "";
            format-paused = "󰏤";
          };

          "group/power" = {
            orientation = "vertical";
            drawer.transition-left-to-right = true;
          };

          "custom/hide".format = "";

          "custom/weather" = {
            format = "{}";
            exec = "wttrbar --date-format %d/%m --nerd --vertical-view";
          };

          clock = {
            format = "󰅐\n{:%H\n%M\n%S} ";
            format-alt = "󰅐\n{:%I\n%M\n\n%d\n%m\n%y} ";
          };

          "group/notify" = {
            orientation = "vertical";
            drawer.transition-left-to-right = true;
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
        (mkMerge [
          panel
          shared
          {
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
        ])
        (mkMerge [
          panel
          shared
          {
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
        ])
      ];
  };
}
