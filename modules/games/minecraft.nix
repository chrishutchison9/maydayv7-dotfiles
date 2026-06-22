## Minecraft ##
_: {
  flake.modules.homeManager.minecraft = _: {
    programs.prismlauncher.enable = true;
    home.persist.directories = [".local/share/PrismLauncher"];
  };
}
