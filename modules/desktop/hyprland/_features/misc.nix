# Web Browser
_: {
  home = _: {
    # GTK Apps
    dconf.settings."org/gnome/desktop/wm/preferences" = {
      action-double-click-titlebar = "none";
      button-layout = "appmenu";
    };

    # Browser
    home.file.".config/mozilla/firefox/default/chrome/userChrome.css".text = ''
      #TabsToolbar {
        -moz-window-dragging: no-drag;
      }
    '';

    # Code Editor
    programs.vscode.profiles.default.userSettings = {
      "window.titleBarStyle" = "custom";
      "window.controlsStyle" = "hidden";
    };
  };
}
