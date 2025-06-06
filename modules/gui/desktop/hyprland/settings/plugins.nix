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
      hyprsplit
      hypr-dynamic-cursors
      Hyprspace
    ];

    settings = {
      plugin = {
        # Workspaces per Monitor
        hyprsplit.num_workspaces = 9;

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

        # Workspace Overview
        overview =
          with sys.lib.stylix.colors;
          let
            gaps = builtins.toString config.wayland.windowManager.hyprland.settings.general.gaps_in;
          in
          {
            autoDrag = true;
            dragAlpha = 0.4;
            exitOnClick = true;
            centerAligned = true;
            hideTopLayers = true;
            hideOverlayLayers = false;
            showNewWorkspace = false;
            showEmptyWorkspace = true;
            overrideGaps = true;
            gapsIn = gaps;
            gapsOut = gaps;
            panelBorderWidth = 0;
            panelBorderColor = "rgb(${base0A})";
            workspaceActiveBorder = "rgb(${base0D})";
          };
      };

      bind = [
        "$mod, grave, overview:toggle"
        "$mod SHIFT, grave, overview:toggle, all"
      ];
    };
  };
}
