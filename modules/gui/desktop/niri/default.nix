{
  config,
  lib,
  util,
  inputs,
  pkgs,
  ...
}@args:
{
  ## Niri Configuration ##
  imports = [ ../_shared ];
  config = lib.mkIf (config.gui.desktop == "niri") (
    lib.mkMerge (
      # App Configuration
      (builtins.map (path: import path args) (util.map.modules.list ./apps))
      ++ [
        ## Environment Setup
        {
          programs = {
            # WM
            niri = {
              enable = true;
              package = pkgs.niri-unstable;
              useNautilus = false;
            };

            # Session
            uwsm = {
              enable = true;
              waylandCompositors = {
                niri = {
                  prettyName = "Niri";
                  comment = "Niri compositor managed by UWSM";
                  binPath = "/run/current-system/sw/bin/niri";
                };
              };
            };
          };

          # App Environment
          xdg.portal.config.niri.default = [
            "gtk"
            "wlr"
          ];

          # Settings
          _shared.enable = true;
          user.homeConfig = {
            imports = [
              inputs.niri.homeModules.config
              ./settings
            ];

            programs.niri = { inherit (config.programs.niri) package; };
          };
        }
      ]
    )
  );
}
