{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    ## Layer Rules
    layerrule = [
      "blur, ^(logout_dialog)$"
      "blur, ^(nwg-drawer)$"
      "blur, ^(waybar)$"
    ];

    ## Window Rules
    windowrulev2 = lib.flatten ([
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
        ]));
  };
}
