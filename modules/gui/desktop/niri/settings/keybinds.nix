{ config, ... }:
{
  programs.niri.settings = {
    input.power-key-handling.enable = false;
    binds =
      with config.lib.niri.actions;
      let
        sh = spawn "sh" "-c";
      in
      {
        # Compositor
        "Super+slash".action = show-hotkey-overlay;
        "Super+Q".action = close-window;
        "Super+C".action = center-window;
        "Super+Shift+E".action = fullscreen-window;
        "Super+equal".action = switch-preset-column-width;
        "Super+minus".action = switch-preset-window-height;
        "Super+Shift+equal".action = maximize-column;
        "Super+Shift+minus".action = set-column-width "+10%";
        "Super+semicolon".action = toggle-window-floating;
        "Super+apostrophe".action = switch-focus-between-floating-and-tiling;
        "Super+Shift+Tab".action = toggle-column-tabbed-display;

        "Super+Tab".action = toggle-overview;
        "Super+Right".action = focus-column-or-monitor-right;
        "Super+Left".action = focus-column-or-monitor-left;
        "Super+Up".action = focus-window-or-workspace-up;
        "Super+Down".action = focus-window-or-workspace-down;

        "Super+Shift+Right".action = consume-or-expel-window-right;
        "Super+Shift+Left".action = consume-or-expel-window-left;
        "Super+Shift+Up".action = move-window-up-or-to-workspace-up;
        "Super+Shift+Down".action = move-window-down-or-to-workspace-down;
        "Super+Shift+Return".action = move-window-to-monitor-next;

        "Super+1".action = focus-workspace 1;
        "Super+2".action = focus-workspace 2;
        "Super+3".action = focus-workspace 3;
        "Super+4".action = focus-workspace 4;
        "Super+5".action = focus-workspace 5;
        "Super+6".action = focus-workspace 6;
        "Super+7".action = focus-workspace 7;
        "Super+8".action = focus-workspace 8;
        "Super+9".action = focus-workspace 9;
        "Super+0".action = focus-workspace 10;

        "Print".action = screenshot;
        "Shift+Print".action.screenshot-screen = [ ]; # https://github.com/sodiboo/niri-flake/issues/922
        "Ctrl+Print".action = screenshot-window;

        # Controls
        "Super+L".action = sh "loginctl lock-session";
        "XF86AudioPlay".action = sh "sysutils media toggle";
        "XF86AudioPrev".action = sh "sysutils media previous";
        "XF86AudioNext".action = sh "sysutils media next";
        "XF86AudioMute".action = sh "sysutils volume mute";
        "XF86AudioRaiseVolume".action = sh "sysutils volume up";
        "XF86AudioLowerVolume".action = sh "sysutils volume down";
        "XF86MonBrightnessUp".action = sh "sysutils brightness up";
        "XF86MonBrightnessDown".action = sh "sysutils brightness down";
        "XF86KbdBrightnessUp".action = sh "sysutils backlight up";
        "XF86KbdBrightnessDown".action = sh "sysutils backlight down";
      };
  };
}
