## Compositor
_: {
  nixos = {pkgs, ...}: {
    # WM
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package = pkgs.hyprworld.hyprland;
      portalPackage = pkgs.hyprworld.xdg-desktop-portal-hyprland;
    };

    # App Environment
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  home = _: {
    home.persist.directories = [".config/hypr"];
  };
}
