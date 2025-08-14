{
  pkgs,
  files,
  theme,
  ...
}:
{
  ## Desktop Integration
  stylix.base16Scheme = files.colors.catppuccin;
  environment.systemPackages = [ pkgs.custom.cursors ];
  gui = with theme; {
    inherit (theme) icons;

    gtk = {
      enable = true;
      theme = gtk;
    };

    qt = {
      enable = true;
      theme = qt;
      style = "kvantum";
    };
  };

  # GTK Apps
  user.homeConfig.dconf.settings."org/gnome/desktop/wm/preferences" = {
    action-double-click-titlebar = "none";
    button-layout = "appmenu";
  };
}
