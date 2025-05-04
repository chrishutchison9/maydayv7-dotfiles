{
  sys,
  config,
  pkgs,
  ...
}:
{
  ## Plugin Settings
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprworld; [
      hyprexpo
      hyprsplit
      hypr-dynamic-cursors
    ];

    settings = {
      plugin = {
        # Workspaces per Monitor
        hyprsplit.num_workspaces = 9;

        # Workspace Overview
        hyprexpo = {
          columns = 3;
          workspace_method = "first 1";
          enable_gesture = true;
          gesture_positive = false;
          gesture_fingers = 4;
          bg_col = "rgb(${sys.lib.stylix.colors.base00})";
          gap_size = config.wayland.windowManager.hyprland.settings.general.gaps_in;
        };

        # Cursor Effects
        dynamic-cursors = {
          enabled = true;
          hyprcursor.enabled = true;
          shake = {
            enabled = true;
            nearest = true;
            effects = false;
            ipc = false;
          };
          mode = if sys.gui.fancy then "tilt" else "none";
          tilt.function = "negative_quadratic";
        };
      };

      # Overview
      bind = [ "$mod, grave, hyprexpo:expo, toggle" ];
    };
  };
}
