## Compositor Plugins
_: {
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
lib.mkIf (osConfig != null) (
  let
    inherit (pkgs.hyprworld) hyprsplitlua hypr-dynamic-cursors;

    lua = import ./_lib.nix lib;
    inherit (lua) inline;

    cursorMode =
      if osConfig.gui.fancy
      then "tilt"
      else "none";
  in {
    # Workspaces per Monitor
    xdg.configFile."hypr/hyprsplit/init.lua".source = "${hyprsplitlua}/share/hyprsplit/init.lua";
    wayland.windowManager.hyprland = {
      settings.hs = {
        _var = inline ''(function() local hs = require("hyprsplit"); hs.config({ num_workspaces = 9 }); return hs end)()'';
      };

      # Cursor Effects
      plugins = [hypr-dynamic-cursors];
      extraConfig = ''
        if hl.plugin.dynamic_cursors then
          hl.config({ plugin = { dynamic_cursors = {
            enabled = true,
            mode = "${cursorMode}",
            hyprcursor = { enabled = true, nearest = 1 },
            shake = { enabled = true, effects = false, ipc = false },
            tilt = { activation = "negative_quadratic" },
          } } })
        end
      '';
    };
  }
)
