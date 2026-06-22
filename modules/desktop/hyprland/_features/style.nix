## Catppuccin Style
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

  home = {
    config,
    lib,
    options,
    ...
  }: let
    inherit (lib) attrNames elem filter genAttrs hasPrefix;

    # Use Catppuccin over Stylix
    alias = {
      qt = "kvantum";
      discord = "vesktop";
      zed = "zed-editor";
    };
    except = ["kitty"];
    targets = filter (n: !hasPrefix "_" n) (attrNames options.stylix.targets);
    derived = filter (t: elem (alias.${t} or t) (attrNames config.catppuccin) && !elem t except) targets;
  in {
    imports = [inputs.catppuccin.homeModules.catppuccin];
    config = {
      gui._unmanaged = derived ++ ["spicetify"];
      catppuccin =
        {
          enable = true;
          accent = "blue";
          flavor = "macchiato";
          hyprland.enable = false;
          gtk.icon.enable = false;
          firefox.force = true;
          kvantum.enable = false;
        }
        // genAttrs except (_: {enable = false;});
    };
  };
}
