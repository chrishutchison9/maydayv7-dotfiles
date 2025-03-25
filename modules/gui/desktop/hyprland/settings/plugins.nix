{
  sys,
  config,
  pkgs,
  ...
}: {
  ## Plugin Settings
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
      hyprsplit
      pkgs.custom.hyprdark
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
      };

      bind = [
        # Overview
        "$mod, grave, hyprexpo:expo, toggle"

        # Color Inversion
        "$mod, I, invertactivewindow"
      ];
    };
  };
}
