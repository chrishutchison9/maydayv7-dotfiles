# Hyprland Utilities
{
  util ? null,
  files ? null,
  ...
}: {
  nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # Apps
      custom.kebihelp
      nwg-displays

      # Utilities
      custom.hyprutils
      grim
      grimblast
      hyprkeys
      hyprshade
      unstable.pyprland
      waycorner
    ];
  };

  home = {
    config,
    pkgs,
    ...
  }: let
    inherit (pkgs.lib) getExe;
    inherit (config.lib.stylix) colors;
  in {
    # Hot Corners
    systemd.user.services.waycorner = let
      target = ["graphical-session.target"];
    in {
      Install.WantedBy = target;
      Unit = {
        Description = "Hot Corners";
        After = target;
      };
      Service.ExecStart = getExe pkgs.waycorner;
    };

    home = {
      persist.directories = [".config/nwg-displays"];
      file = with files.hyprland; {
        # Pyprland
        ".config/pypr/config.toml".text = pypr;

        # Hot Corners
        ".config/waycorner/config.toml".text = waycorner;

        # Keybinds Viewer
        ".config/kebihelp.json".text = util.build.theme {
          inherit colors;
          inherit (config.stylix) fonts;
          file = kebihelp;
        };

        # Shaders
        ".config/hypr/shaders" = {
          source = shaders;
          recursive = true;
        };
      };
    };
  };
}
