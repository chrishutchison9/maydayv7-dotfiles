## Compositor
_: {
  nixos = {pkgs, ...}: {
    # WM
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
  };

  home = {pkgs, ...}: {
    programs.niri.package = pkgs.niri;
    home.persist.directories = [".config/niri"];
  };
}
