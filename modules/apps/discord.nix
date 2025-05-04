{
  config,
  lib,
  pkgs,
  files,
  ...
}:
with files.vesktop;
let
  enable = builtins.elem "discord" config.apps.list;
in
{
  ## Discord Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.vesktop ];

    user = {
      persist.directories = [ ".config/vesktop" ];
      homeConfig.home.file = {
        ".config/vesktop/settings.json".text = prefs;
        ".config/vesktop/settings/settings.json".text = settings;
      };
    };
  };
}
