{
  config,
  util,
  pkgs,
  files,
  ...
}:
{
  # File Picker
  environment.systemPackages = [ pkgs.nautilus ];

  user.homeConfig = {
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
