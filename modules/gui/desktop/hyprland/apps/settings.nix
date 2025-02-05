{
  config,
  lib,
  util,
  pkgs,
  files,
  theme,
  ...
}: {
  ## App Environment
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # Desktop Integration
  stylix.base16Scheme = files.colors.catppuccin;
  gui = with theme; {
    fonts.enable = true;
    inherit (theme) icons;
    launcher.theme = theme.name;

    gtk = {
      enable = true;
      theme = gtk;
    };

    qt = {
      enable = true;
      theme = qt;
    };
  };

  user.homeConfig = {
    # GTK Apps
    dconf.settings."org/gnome/desktop/wm/preferences" = {
      action-double-click-titlebar = "none";
      button-layout = "appmenu";
    };

    wayland.windowManager.hyprland.settings = {
      env = [
        # QT Apps
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"

        # Screengrab
        "SLURP_ARGS, -dc ${config.lib.stylix.colors.base0D}"
      ];

      ## Shortcuts
      bind = let
        toggle = app: "pkill ${app} || uwsm app -u ${app}.scope -- ${app}";
        runOnce = app: "pgrep ${app} || uwsm app -u ${app}.scope -- ${app}";
      in [
        "$mod SHIFT, slash, exec, ${toggle "kebihelp"} show -a"
        "$mod, slash, exec, ulauncher-toggle"
        "$mod, A, exec, nwg-drawer"
        "$mod SHIFT, A, exec, hyprutils toggle panel"
        "$mod SHIFT, C, exec, ${runOnce "hyprpicker"} -arf hex"
        "$mod, D, exec, pypr toggle displays"
        "$mod, F, exec, nemo"
        "$mod, N, exec, dunstctl history-pop"
        "$mod, T, exec, kitty"
        "$mod SHIFT, T, exec, pypr toggle term"
        ''$mod, V, exec, sh -c "hyprctl clients | grep 'class: clipse' || pypr show clip"''
        "$mod, W, exec, firefox"
        "$mod, Return, exec, ${runOnce "missioncenter"}"
        ", XF86Calculator, exec, qalculate-gtk"
        "$mod, Escape, exec, ${toggle "wlogout"} -p layer-shell"
      ];

      ## Autostart
      exec-once =
        ["uwsm finalize"]
        ++ (builtins.map (app: "uwsm app -t service -u ${util.build.until " " app}.service -- " + app) [
          "hyprutils daemon"

          # Application Drawer
          "nwg-drawer -r"

          # Clipboard Manager
          "clipse -listen"

          # Desktop Icons
          "dicons"

          # Pyprland
          "pypr"
        ]);

      ## Layer Rules
      layerrule = [
        "blur, ^(logout_dialog)$"
        "blur, ^(nwg-drawer)$"
        "blur, ^(waybar)$"
      ];

      ## Window Rules
      windowrulev2 = lib.flatten ([
          "pin, class:^(gnome-control-center)$"

          # Clipboard Manager
          "float, class:^(clipse)$"

          # Application Launcher
          "opacity 0.9 override, class:^(ulauncher)$"
          "move cursor -50% -50%, class:^(ulauncher)$"

          # Keybinds Viewer
          "pin, title:^(Kebihelp)$"
          "float, title:^(Kebihelp)$"
          "stayfocused, title:^(Kebihelp)$"
          "opacity 0.9 override, title:^(Kebihelp)"

          # Browser Windows
          "float, title:^(Picture-in-Picture)$"
          "workspace special silent, title:^(Sharing Indicator)$"
          "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"

          # Media Consumption
          "idleinhibit focus, class:^(mpv|.*celluloid.*|.+exe)$"
          "idleinhibit focus, class:^(firefox|google-chrome)$, title:^(.*YouTube.*)$"
          "idleinhibit fullscreen, class:^(firefox|google-chrome)$"

          # Screen Tearing
          "immediate, class:^(.+exe)$"

          # Prompt Windows
          "dimaround, class:^(xdg-desktop-portal-gtk)"
        ]
        ++ (builtins.map (class: [
            "pin, class:^(${class})"
            "dimaround, class:^(${class})"
            "stayfocused, class:^(${class})"
          ]) [
            "pinentry-"
            "gay.vaskel.Soteria"
          ])
        ++ (builtins.map (title: [
            # Dialogs
            "float, title:^(${title})(.*)$"
          ]) [
            "Library"
            "Open File"
            "Open Folder"
            "Save As"
            "Save File"
            "Select a File"
            ".*Properties"
          ]));
    };
  };
}
