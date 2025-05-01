{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (builtins.elem "osu" config.apps.games) {
    environment.systemPackages = [pkgs.osu-lazer-bin];
    user.persist.directories = [".local/share/osu"];
  };
}
