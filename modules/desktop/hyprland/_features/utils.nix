## Utilities
{
  util ? null,
  files ? null,
  ...
}: {
  nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      custom.kebihelp
      custom.hyprutils
      unstable.pyprland
      hyprshade
    ];
  };

  home = {config, ...}: {
    home.file = with files.hyprland; {
      # Pyprland
      ".config/pypr/config.toml".text = pypr;

      # Keybinds Viewer
      ".config/kebihelp.json".text = util.build.theme {
        inherit (config.stylix) fonts;
        inherit (config.lib.stylix) colors;
        file = kebihelp;
      };

      # Shaders
      ".config/hypr/shaders" = {
        source = shaders;
        recursive = true;
      };
    };
  };
}
