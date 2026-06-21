## Minecraft ##
_: {
  flake.modules.homeManager.minecraft = {pkgs, ...}: {
    programs.prismlauncher.enable = true;
    home.persist.directories = [".local/share/PrismLauncher"];
  };
}
