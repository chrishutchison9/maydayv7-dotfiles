{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  enable = builtins.elem "flatpak" config.apps.list;
  theme = config.gui.gtk.theme.name;
in
{
  ## Flatpak Configuration ##
  imports = [ inputs.flatpak.nixosModules.nix-flatpak ];

  config = lib.mkIf enable {
    warnings = [
      ''
        Flatpak support is enabled
        - App install isn't generational (Changes in configuration will result in downloading them anew)
        - Updates must be managed manually
      ''
    ];

    xdg.portal.enable = true;
    system.activationScripts.updateDesktopDatabase.text = "${pkgs.desktop-file-utils}/bin/update-desktop-database /var/lib/flatpak/exports/share/applications";

    environment.persist.directories = [ "/var/lib/flatpak" ];
    user.homeConfig.home.persist.directories = [
      ".cache/flatpak"
      ".local/share/flatpak"
      ".var/app"
    ];

    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;

      # Repositories
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];

      # Package List
      # Use 'flatpak remote-info --log' to find commit revisions
      packages = [
        /*
          {
            appId = "";
            origin = "";
            commit = "";
          }
        */
      ];

      # Platform Integration
      overrides.global = {
        Context = {
          filesystems = [
            "~/.config/dconf:ro"
            "/run/current-system/sw/share/themes:ro"
          ];

          sockets = [
            "wayland"
            "!x11"
            "fallback-x11"
          ];
        };

        Environment = {
          "DCONF_USER_CONFIG_DIR" = ".config/dconf";
          "GTK_THEME" = theme;
        };
      };

      # Package Updates
      update = {
        onActivation = false;
        auto.enable = false;
      };
    };
  };
}
