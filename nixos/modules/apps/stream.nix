{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = builtins.elem "stream" config.apps.list;
in
{
  ## Streaming Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.stremio-linux-shell ];
    user.homeConfig.home.persist.directories = [
      ".stremio-server"
      ".local/share/stremio"
    ];
  };
}
