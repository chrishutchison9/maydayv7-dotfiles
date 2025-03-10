{
  sys,
  config,
  pkgs,
  ...
}: {
  ## Plugin Settings
  wayland.windowManager.hyprland = {
    plugins = with pkgs.hyprworld; [
      Hypr-DarkWindow
      hyprsplit
      hyprtasking
    ];

    settings = {
      plugin = let
        inherit (config.wayland.windowManager.hyprland.settings) general;
      in {
        # Overview
        hyprtasking = {
          layout = "grid";
          inherit (general) border_size;
          gap_size = general.gaps_in;
          exit_behavior = "interacted";
          bg_color = "0x${sys.lib.stylix.colors.base00-hex}";
          gestures = {
            enabled = true;
            open_fingers = 3;
            open_positive = true;
          };

          grid = {
            rows = 3;
            cols = 3;
          };
        };

        # Split Monitor Workspaces
        hyprsplit.num_workspaces = 9;
      };

      bind = [
        # Overview
        "$mod, Tab, hyprtasking:toggle, cursor"
        "$mod SHIFT, Tab, hyprtasking:toggle, all"
        "$mod, Q, hyprtasking:killhovered"

        # Compositor Shaders
        "$mod, S, exec, hyprutils toggle shader"
        "$mod SHIFT, S, invertactivewindow"
      ];
    };
  };
}
