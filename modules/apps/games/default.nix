{
  config,
  lib,
  util,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkOverride
    types
    ;

  inherit (util.map) modules;
  enable = builtins.elem "games" config.apps.list;
  wine = builtins.elem "wine" config.apps.list;
in
{
  imports = modules.list ./.;

  options.apps.games = mkOption {
    description = "List of Installed Games";
    type = types.listOf (types.enum (modules.name ./.));
    default = [ ];
  };

  ## Games Configuration ##
  config = mkIf enable {
    # Packages
    environment.systemPackages = with pkgs; [
      bottles
      lutris
    ];

    # Steam
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # Game Mode
    hardware.cpu.mode = mkOverride 51 "performance";
    gui.fancy = mkOverride 999 false;
    programs.gamemode.enable = true; # Use 'gamemoderun %command%'

    user.homeConfig = {
      # Runner
      xdg.dataFile."lutris/runners/wine/wine-system" = mkIf wine {
        source = config.apps.wine.package;
      };

      # Directories
      home.persist.directories = [
        "Games"
        ".local/share/bottles"

        # Lutris
        ".cache/lutris"
        ".config/lutris"
        ".local/share/lutris"

        # Steam
        ".local/share/applications"
        ".local/share/icons/hicolor"
        ".steam"
        ".local/share/Steam"
      ];
    };
  };
}
