{
  config,
  lib,
  pkgs,
  ...
}:
{
  ## OSU! ##
  config = lib.mkIf (builtins.elem "osu" config.apps.games) {
    environment.systemPackages = [ pkgs.osu-lazer-bin ];
    user.homeConfig.home.persist.directories = [ ".local/share/osu" ];
  };
}
