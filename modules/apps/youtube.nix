{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = builtins.elem "youtube" config.apps.list;
in
{
  ## YT Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      youtube-music
      youtube-tui
      yt-dlp
    ];

    user.persist.directories = [
      ".config/YouTube Music"
      ".config/youtube-tui"
      ".local/share/youtube-tui"
    ];
  };
}
