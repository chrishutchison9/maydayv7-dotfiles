{
  pkgs,
  util,
  files,
  theme,
  ...
}: {
  ## Text Editor Configuration
  environment.systemPackages = [pkgs.geany];
  user = {
    persist.directories = [".config/geany"];
    homeConfig = {
      xdg.mimeApps.defaultApplications = util.build.mime files.xdg.mime {
        markdown = ["geany.desktop"];
        text = ["geany.desktop"];
      };

      home.file = with files.geany; {
        ".config/geany/geany.conf".text = settings;
        ".config/geany/keybindings.conf".text = keybindings;
        ".config/geany/colorschemes/theme.conf".source = with theme; "${pkgs.custom.geany-catppuccin}/share/geany/colorschemes/${name}-${variant}.conf";
      };
    };
  };
}
