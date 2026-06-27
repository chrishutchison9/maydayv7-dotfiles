## Spotify Configuration ##
{inputs, ...}: {
  flake.modules.homeManager.spotify = {
    lib,
    pkgs,
    osConfig ? {},
    ...
  }: let
    isWM = (osConfig.programs.hyprland.enable or false) || (osConfig.programs.niri.enable or false);
  in {
    imports = [inputs.spicetify.homeManagerModules.default];
    home.persist.directories = [
      ".config/spotify"
      ".cache/spotify"
    ];

    programs.spicetify =
      {
        enable = true;

        # Player Improvements
        enabledCustomApps = with pkgs.spicetify.apps; [
          betterLibrary
          localFiles
          newReleases
        ];

        enabledExtensions = with pkgs.spicetify.extensions; [
          goToSong
          history
          loopyLoop
          playNext
          popupLyrics
          seekSong
          showQueueDuration
          volumePercentage
        ];
      }
      // lib.optionalAttrs isWM {
        theme = pkgs.spicetify.themes.catppuccin;
        colorScheme = "macchiato";
      };
  };
}
