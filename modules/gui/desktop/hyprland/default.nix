{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}@args:
let
  inherit (lib)
    getExe
    mkForce
    mkIf
    mkMerge
    replaceStrings
    ;

  inherit (util.map.modules) list;
  inherit (config.gui) desktop;
in
{
  ## Hyprland Configuration ##
  config = mkIf (desktop == "hyprland") (
    mkMerge (
      # App Configuration
      (builtins.map (path: import path (args // { theme = import ../common/theme.nix pkgs; })) (
        list ../common/apps ++ list ./apps
      ))
      ++ [
        ## Environment Setup
        rec {
          # WM
          programs.hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
            package = pkgs.hyprworld.hyprland;
            portalPackage = pkgs.hyprworld.xdg-desktop-portal-hyprland;
          };

          services = {
            xserver.desktopManager.runXdgAutostartIfNone = true;

            # Greeter
            greetd.settings.default_session.command = mkForce "${getExe programs.hyprland.package} --config ${
              pkgs.writeText "greeter.conf" (
                replaceStrings [ "@greeter" ] [ (getExe config.programs.regreet.package) ] (
                  util.build.theme {
                    inherit (config.lib.stylix) colors;
                    file = files.hyprland.greeter;
                  }
                )
              )
            } &> /dev/null";
          };
        }
        {
          # App Environment
          xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

          # Settings
          user = {
            persist.directories = [ ".config/hypr" ];
            homeConfig.imports = [ ./settings ];
          };
        }
      ]
    )
  );
}
