{
  config,
  lib,
  pkgs,
  ...
}:
{
  ## Minecraft ##
  config = lib.mkIf (builtins.elem "minecraft" config.apps.games) {
    environment.systemPackages = [ pkgs.prismlauncher ];
    user.homeConfig.home.persist.directories = [ ".local/share/PrismLauncher" ];
  };
}
