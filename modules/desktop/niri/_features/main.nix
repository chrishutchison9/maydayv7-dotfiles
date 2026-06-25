## Compositor
_: {
  nixos = {pkgs, ...}: {
    # WM
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    # Session
    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/niri";
      };
    };

    # App Environment
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  home = {pkgs, ...}: {
    programs.niri.package = pkgs.niri;
    home.persist.directories = [".config/niri"];
  };
}
