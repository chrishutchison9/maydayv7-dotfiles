{
  config,
  lib,
  util,
  inputs,
  pkgs,
  ...
}@args:
let
  inherit (lib) mkIf mkMerge;
  inherit (util.map.modules) list;
  inherit (config.gui) desktop;
in
{
  ## Niri Configuration ##
  config = mkIf (desktop == "niri") (
    mkMerge (
      # App Configuration
      (builtins.map (path: import path (args // { theme = import ../common/theme.nix pkgs; })) (
        list ../common/apps ++ list ./apps
      ))
      ++ [
        ## Environment Setup
        {
          # WM
          programs.niri = {
            enable = true;
            package = pkgs.niri-stable;
          };
        }
        {
          # Settings
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
