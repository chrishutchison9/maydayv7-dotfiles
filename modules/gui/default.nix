{
  config,
  options,
  lib,
  util,
  pkgs,
  ...
}: let
  inherit (builtins) map;
  inherit (util.map.modules) list name;
  inherit (lib) hasSuffix mkEnableOption mkForce mkIf mkMerge mkOption optional types;
  inherit (config.gui) desktop;
in {
  ## GUI Configuration ##
  imports = list ./. ++ list ./desktop;

  options.gui = {
    fancy = mkEnableOption "Enable Fancy GUI Effects";
    display = mkOption {
      description = "Main GUI Display";
      type = types.str;
      default = "eDP-1";
      example = "HDMI-A-1";
    };

    desktop = mkOption {
      description = "GUI Desktop Choice";
      type = types.enum ((name ./desktop) ++ map (x: x + "-iso") (import ./desktop/iso.nix) ++ [""]);
      default = "";
    };
  };

  config = mkMerge [
    {warnings = optional (desktop == "") (options.gui.desktop.description + " is unset");}

    ## Desktop Environment
    (mkIf (desktop != "" && !(hasSuffix "-iso" desktop))
      {
        user.persist.directories = [".config/autostart" ".local/share/gvfs-metadata"];

        # Utilities
        programs.seahorse.enable = true;
        user.homeConfig.services.mpris-proxy.enable = true;
        services = {
          gvfs.enable = true;
          gnome.gnome-keyring.enable = true;
        };

        # Desktop Integration
        environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"];
        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
        };
      })

    ## Install Media
    (mkIf (hasSuffix "-iso" desktop) {
      xdg.portal.enable = mkForce false;
      environment.systemPackages = with pkgs; [epiphany gparted];
    })
  ];
}
