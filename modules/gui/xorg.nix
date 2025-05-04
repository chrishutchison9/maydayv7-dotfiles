{ lib, ... }:
let
  inherit (lib)
    mkDefault
    mkForce
    mkOption
    types
    ;
in
{
  options.gui.xorg.enable = mkOption {
    description = "Enable X11 Server Configuration";
    type = types.bool;
    default = true;
  };

  ## X11 Server Configuration ##
  config = {
    services.xserver = {
      enable = true;
      autorun = true;

      # Driver Settings
      videoDrivers = mkDefault [ "modesetting" ];
    };

    user.homeConfig.xresources.extraConfig = ''
      Xft.antialias: 1
      Xft.autohint: 0
      Xft.hinting: 1
      Xft.hintstyle: hintslight
      Xft.lcdfilter: lcddefault
      Xft.rgba: rgb
    '';

    # System Specialisation
    specialisation.xorg.configuration = {
      system.nixos.label = "special.xorg";
      gui.wayland.enable = mkForce false;
      hardware.vm.android.enable = mkForce false;
    };
  };
}
