{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}:
let
  enable = builtins.elem "office" config.apps.list;
in
{
  ## Office Environment Configuration ##
  config = lib.mkIf enable {
    environment = {
      systemPackages = with pkgs; [
        # Productivity
        calibre
        gscan2pdf
        keepassxc
        libreoffice
        onlyoffice-desktopeditors
        pdfarranger
        simple-scan

        # Graphics
        gimp3
        handbrake
        inkscape
        xournalpp

        # Dictionary
        hunspell
        hunspellDicts.en_US-large
        hyphen
      ];

      variables."DICPATH" = "/run/current-system/sw/share/hunspell:/run/current-system/sw/share/hyphen";
      pathsToLink = [
        "/share/hunspell"
        "/share/myspell"
        "/share/hyphen"
      ];
    };

    user.homeConfig = {
      xdg.mimeApps.defaultApplications = util.build.mime {
        office = [ "onlyoffice-desktopeditors.desktop" ];
        password = [ "org.keepassxc.KeePassXC.desktop" ];
      };

      # Password Manager
      programs.keepassxc.enable = true;

      home = {
        persist = {
          files = [ ".config/gscan2pdfrc" ];
          directories = [
            ".calibre"
            ".config/calibre"
            ".config/GIMP"
            ".cache/gimp"
            ".config/inkscape"
            ".config/keepassxc"
            ".cache/keepassxc"
            ".config/libreoffice"
            ".config/onlyoffice"
            ".local/share/onlyoffice"
            ".local/share/data"
          ];
        };

        file = {
          # Document Templates
          "Templates" = rec {
            source = files.templates;
            target = ".init-templates";
            onChange = ''
              rm -rf ~/Templates
              cp -rL ~/${target} ~/Templates
              chmod -R 0777 ~/Templates
            '';
          };

          # Font Rendering
          ".local/share/fonts" = {
            source = "${pkgs.custom.fonts}/share/fonts";
            recursive = true;
          };
        };
      };
    };
  };
}
