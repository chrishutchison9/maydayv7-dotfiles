{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  enable = builtins.elem "spotify" config.apps.list;
in
{
  ## Spotify Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      spotify
      spot
      spicetify-cli
    ];

    user = {
      persist.directories = [
        ".config/spotify"
        ".cache/spotify"
        ".cache/spot"
      ];

      homeConfig = {
        imports = [ inputs.spicetify.homeManagerModules.default ];
        programs.spicetify = {
          enable = true;

          # Player Improvements
          enabledCustomApps = with pkgs.spicetify.apps; [
            betterLibrary
            localFiles
            newReleases
          ];

          enabledExtensions = with pkgs.spicetify.extensions; [
            beautifulLyrics
            goToSong
            history
            loopyLoop
            playNext
            popupLyrics
            seekSong
            showQueueDuration
            volumePercentage
          ];
        };
      };
    };
  };
}
