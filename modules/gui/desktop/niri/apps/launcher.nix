{
  config,
  util,
  pkgs,
  files,
  ...
}:
{
  ## Launcher Configuration
  user = {
    persist.directories = [ ".cache/rofi" ];
    homeConfig = {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi;
        configPath = ".config/rofi/main.rasi";
        plugins = with pkgs; [
          rofi-calc
          rofi-emoji
        ];
      };

      stylix.targets.rofi.enable = true;
      home.file.".config/rofi/config.rasi".text = util.build.theme {
        inherit (config.lib.stylix) colors;
        file = files.niri.rofi;
      };
    };
  };
}
