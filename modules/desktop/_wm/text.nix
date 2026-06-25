## Text Editor
{
  util ? null,
  files ? null,
  ...
}: {
  nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.geany];
  };

  home = {pkgs, ...}: {
    xdg.mimeApps.defaultApplications = util.build.mime {
      markdown = ["geany.desktop"];
      text = ["geany.desktop"];
    };

    home = {
      persist.directories = [".config/geany"];
      file = with files.geany; {
        ".config/geany/geany.conf".text = settings;
        ".config/geany/keybindings.conf".text = keybindings;
        ".config/geany/colorschemes/theme.conf".source = "${pkgs.custom.geany-catppuccin}/share/geany/colorschemes/catppuccin-macchiato.conf";
      };
    };
  };
}
