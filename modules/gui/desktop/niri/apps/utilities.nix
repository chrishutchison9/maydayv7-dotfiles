{
  config,
  util,
  files,
  ...
}:
{
  user.homeConfig = {
    # Portals
    xdg.portal.config.niri = {
      default = [
        "gnome"
        "gtk"
      ];

      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.Background" = [ "gnome" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
    };

    # Wallpaper
    stylix.targets.wpaperd.enable = true;
    services = {
      wpaperd.enable = true;

      # Notifications
      dunst.settings.global.origin = "top-left";
    };

    # Application Drawer
    home.file.".config/nwg-drawer/drawer.css".text = util.build.theme {
      inherit (config.lib.stylix) colors;
      file = files.niri.drawer;
    };
  };
}
