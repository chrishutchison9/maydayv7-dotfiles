{
  inputs,
  files ? null,
  ...
}: {
  nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.custom.cursors];
    stylix = {
      base16Scheme = files.colors.catppuccin;
      icons.package = pkgs.catppuccin-papirus-folders.override {
        accent = "blue";
        flavor = "macchiato";
      };
    };

    gui = {
      gtk.theme = {
        name = "catppuccin-macchiato-blue-standard";
        package = pkgs.catppuccin-gtk.override {
          accents = ["blue"];
          variant = "macchiato";
        };
      };

      qt = {
        style = "kvantum";
        theme = {
          name = "catppuccin-macchiato-blue";
          package = pkgs.catppuccin-kvantum.override {
            accent = "blue";
            variant = "macchiato";
          };
        };
      };
    };
  };

  home = _: {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    config = {
      # Theme
      catppuccin = {
        accent = "blue";
        flavor = "macchiato";

        brave.enable = true;
        thunderbird.enable = true;
        obs.enable = true;
        vesktop.enable = true;
        vscode.profiles.default.enable = true;
      };

      # Browser
      programs.firefox.policies.ExtensionSettings = {
        name = "catppuccin-macchiato-blue";
        value = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/{d49033ac-8969-488c-afb0-5cdb73957f41}/latest.xpi";
        };
      };
    };
  };
}
