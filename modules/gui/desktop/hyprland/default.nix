{
  config,
  lib,
  util,
  pkgs,
  ...
} @ args: let
  inherit (config.gui) desktop;
  inherit (lib) mkForce mkIf mkMerge;
  theme = import ./theme.nix pkgs;
in {
  ## Hyprland Configuration ##
  config = mkIf (desktop == "hyprland") (
    mkMerge (
      # App Configuration
      (builtins.map (path: import path (args // {inherit theme;}))
        (util.map.modules.list ./apps))
      ++ [
        ## Environment Setup
        {
          gui = {
            xorg.enable = false;
            wayland.enable = true;
            launcher = {
              enable = true;
              shadow = false;
            };
          };

          programs = {
            # WM
            hyprland = {
              enable = true;
              withUWSM = true;
              xwayland.enable = true;
              package = pkgs.hyprworld.hyprland;
              portalPackage = pkgs.hyprworld.xdg-desktop-portal-hyprland;
            };

            # Login
            regreet = {
              enable = true;
              package = pkgs.greetd.regreet;
              cageArgs = ["-s" "-m" "last"];
              settings.commands = {
                reboot = ["systemctl" "reboot"];
                poweroff = ["systemctl" "poweroff"];
              };
            };
          };

          # Session
          services.xserver.desktopManager.runXdgAutostartIfNone = true;
        }
        {
          # Greeter
          environment.persist.directories = ["/var/cache/regreet"];
          stylix.targets.regreet.enable = true;
          programs.regreet = {
            extraCss = mkForce "";
            theme = mkForce theme.gtk;
            iconTheme = mkForce theme.icons;
          };

          # Settings
          user = {
            persist.directories = [".config/hypr"];
            homeConfig.imports = [./settings];
          };
        }
      ]
    )
  );
}
