{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = builtins.elem "media" config.apps.list;
in
{
  ## Media Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      identity
      pitivi
      vipsdisp

      pwvucontrol
      qpwgraph

      stremio-linux-shell
    ];

    user = {
      persist = {
        files = [ ".config/rncbc.org/qpwgraph" ];
        directories = [
          ".config/pitivi"
          ".stremio-server"
          ".local/share/stremio"
        ];
      };

      # Audio Effects
      homeConfig.services.easyeffects.enable = true;
    };
  };
}
