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
          # WM
          programs.niri = {
            enable = true;
            package = pkgs.niri-stable;
          };

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
