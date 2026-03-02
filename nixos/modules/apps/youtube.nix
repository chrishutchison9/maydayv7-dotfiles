{
  config,
  lib,
  pkgs,
  files,
  ...
}:
let
  inherit (builtins) elem toFile;
  inherit (lib)
    mkIf
    mkOption
    replaceStrings
    types
    ;

  enable = elem "youtube" config.apps.list;
in
{
  ## YT Configuration ##
  options.apps.ytmusic.style = mkOption {
    description = "YouTube Music CSS";
    type = types.str;
    default = "";
  };

  config = mkIf enable {
    environment.systemPackages = with pkgs; [
      youtube-music
      youtube-tui
      yt-dlp
    ];

    user.homeConfig.home = {
      persist.directories = [
        ".config/YouTube Music"
        ".config/youtube-tui"
        ".local/share/youtube-tui"
      ];

      file.".config/YouTube Music/config.json" = {
        text =
          replaceStrings
            [ "@theme" ]
            [
              (toFile "style.css" config.apps.ytmusic.style)
            ]
            files.youtube;
        mutable = true;
        force = true;
      };
    };
  };
}
