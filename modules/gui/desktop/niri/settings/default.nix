{ util, ... }:
{
  imports = util.map.modules.list ./.;
  programs.niri.settings = {
    screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d-%H%M%S.png";
    hotkey-overlay = {
      skip-at-startup = true;
      hide-not-bound = true;
    };

    input = {
      keyboard.numlock = true;
      warp-mouse-to-focus.enable = true;
      workspace-auto-back-and-forth = true;
      focus-follows-mouse.enable = true;
    };

    layout = {
      tab-indicator = {
        enable = true;
        place-within-column = true;
      };

      default-column-width.proportion = 0.5;
      preset-column-widths = [
        { proportion = 1.0 / 3.0; }
        { proportion = 0.5; }
        { proportion = 2.0 / 3.0; }
        { proportion = 0.85; }
      ];
      preset-window-heights = [
        { proportion = 1.0 / 3.0; }
        { proportion = 0.5; }
        { proportion = 2.0 / 3.0; }
        { proportion = 1.0; }
      ];
    };
  };
}
