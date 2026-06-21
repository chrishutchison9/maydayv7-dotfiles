## Compositor Plugins
_: {
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
lib.mkIf (osConfig != null) (
  let
    inherit (pkgs.hyprworld) hyprsplitlua hypr-dynamic-cursors Hyprspace;

    lua = import ./_lib.nix lib;
    inherit (lua) inline;

    inherit (osConfig.gui) fancy;
    inherit (osConfig.lib.stylix.colors) base00 base0D;

    cursorMode =
      if fancy
      then "tilt"
      else "none";
  in {
    # Workspaces per Monitor
    xdg.configFile."hypr/hyprsplit/init.lua".source = "${hyprsplitlua}/share/hyprsplit/init.lua";
    wayland.windowManager.hyprland = {
      settings.hs = {
        _var = inline ''(function() local hs = require("hyprsplit"); hs.config({ num_workspaces = 9 }); return hs end)()'';
      };

      plugins = [hypr-dynamic-cursors Hyprspace];
      extraConfig = ''
        -- Cursor Effects
        if hl.plugin.dynamic_cursors then
          hl.config({ plugin = { dynamic_cursors = {
            enabled = true,
            mode = "${cursorMode}",
            hyprcursor = { enabled = true, nearest = 1 },
            shake = { enabled = true, effects = false, ipc = false },
            tilt = { activation = "negative_quadratic" },
          } } })
        end

        -- Workspace Overview
        if hl.plugin.Hyprspace then
          hl.config({ plugin = { hyprspace = {
            auto_drag = true,
            drag_alpha = 0.4,
            exit_on_click = true,
            center_aligned = true,
            hide_top_layers = true,
            hide_overlay_layers = false,
            show_new_workspace = false,
            show_empty_workspace = true,
            panel_border_width = 0,
            workspace_margin = 10,
            panel_color = "rgb(${base00})",
            workspace_active_border = "rgb(${base0D})",
            swipe_fingers = 4,
          } } })
        end
      '';
    };
  }
)
