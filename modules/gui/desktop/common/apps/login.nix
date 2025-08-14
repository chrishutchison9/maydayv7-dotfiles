{
  lib,
  pkgs,
  theme ? import ./theme.nix pkgs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  ## Login Configuration ##
  stylix.targets.regreet.enable = true;
  environment.persist.directories = [ "/var/lib/regreet" ];
  programs.regreet = {
    enable = true;
    package = pkgs.greetd.regreet;
    settings.commands = {
      reboot = [
        "systemctl"
        "reboot"
      ];
      poweroff = [
        "systemctl"
        "poweroff"
      ];
    };

    extraCss = mkForce "";
    theme = mkForce theme.gtk;
    iconTheme = mkForce theme.icons;
  };
}
