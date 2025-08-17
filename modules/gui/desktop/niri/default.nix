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
  imports = [ ../shared/_default.nix ];
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
          shared.enable = true;
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
