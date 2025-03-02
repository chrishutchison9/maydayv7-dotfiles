{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOverride;
  enable = builtins.elem "games" config.apps.list;
  wine = builtins.elem "wine" config.apps.list;
in {
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
    apps.wine.package = pkgs.gaming.wine-ge;
    environment.systemPackages = with pkgs; [
      bottles
      lutris
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

    # Directories
    user.persist.directories = [
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
}
