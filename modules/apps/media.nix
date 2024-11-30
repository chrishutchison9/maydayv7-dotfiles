{
  config,
  lib,
  pkgs,
  ...
}: let
  enable = builtins.elem "media" config.apps.list;
in {
  ## Media Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      pitivi
      pwvucontrol
      qpwgraph
    ];

    user = {
      persist = {
        files = [".config/rncbc.org/qpwgraph"];
        directories = [".config/pitivi"];
      };

      # Audio Effects
      homeConfig.services.easyeffects.enable = true;
    };
  };
}
