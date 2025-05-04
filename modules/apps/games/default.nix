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
  wine' = pkgs.gaming.wine-tkg;
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
    assertions = [
      {
        assertion = wine;
        message = ''
          Wine support is required
          - Add 'wine to 'apps.list'
        '';
      }
    ];

    # Packages
    environment.systemPackages = with pkgs; [
      bottles
      lutris
      wine'
    ];

    # Steam
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # Game Mode
    # See https://github.com/FeralInteractive/gamemode
    hardware.cpu.mode = mkOverride 51 "performance";
    gui.fancy = mkOverride 999 false;
    programs.gamemode.enable = true;

    user = {
      # Runner
      homeConfig.xdg.dataFile."lutris/runners/wine/wine-tkg".source = wine';

      # Directories
      persist.directories = [
        "Games"
        ".cache/lutris"
        ".config/lutris"
        ".local/share/bottles"
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
