{ config, ... }:
{
  programs.niri.settings = {
    ## Autostart
    spawn-at-startup =
      let
        sh = command: [
          "sh"
          "-c"
          command
        ];
      in
      [
        {
          command = [
            "pcmanfm-qt"
            "--desktop"
          ];
        }
        { command = sh "nwg-drawer -r"; }
      ];

    ## Keybindings
    binds =
      with config.lib.niri.actions;
      let
        sh = spawn "sh" "-c";
        toggle = app: args: sh "pkill ${app} || ${app} ${args}";
        runOnce = app: args: sh "pgrep ${app} || ${app} ${args}";
      in
      {
        # Applications
        "Super+space".action = toggle "rofi" "-show";
        "Super+A".action = spawn "nwg-drawer";
        "Super+F".action = spawn "nemo";
        "Super+T".action = spawn "kitty";
        "Super+W".action = spawn "firefox";
        "Super+Return".action = runOnce "resources" "";
        "XF86Calculator".action = spawn "qalculate-gtk";

        # Utilities
        "Super+N".action = spawn "dunstctl" "history-pop";
        "Super+V".action = spawn "kitty" "--class=clipboard" "-e" "clipse";
        "Super+Shift+C".action = runOnce "hyprpicker" "-arf hex";
        "Super+Shift+B".action = runOnce "overskride" "";
        "Super+Shift+N".action = sh "env XDG_CURRENT_DESKTOP=GNOME gnome-control-center wifi";
        "Super+Shift+P".action = spawn "pavucontrol";
        "Super+Escape".action = toggle "wlogout" "-p layer-shell";
      };

    ## Window Rules
    window-rules = [
      {
        matches = [
          { app-id = "clipboard"; }
          { app-id = "qalculate-gtk"; }
        ];
        open-floating = true;
        default-floating-position = {
          relative-to = "right";
          x = 5;
          y = 0;
        };
      }
      {
        matches = [
          { app-id = "com.saivert.pwvucontrol"; }
          { app-id = "com.github.wwmm.easyeffects"; }
        ];
        open-floating = true;
      }
    ];
  };
}
