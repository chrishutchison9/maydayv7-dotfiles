{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  mutable = {
    mutable = true;
    force = true;
  };

  enable = builtins.elem "notes" config.apps.list;
  cfg = config.apps.logseq;
in
{
  options.apps.logseq.style = mkOption {
    description = "Path to Logseq Notes CSS";
    type = types.str;
    default = "";
  };

  ## Logseq Configuration ##
  config = mkIf enable {
    environment.systemPackages = [ pkgs.logseq ];

    user = {
      persist.directories = [
        ".logseq"
        ".config/Logseq"
      ];

      homeConfig.home.file =
        with files.logseq;
        {
          ".config/logseq/configs.edn".text = ''{:window/native-titlebar? true}'';
          ".logseq/preferences.json" = {
            text = prefs;
          }
          // mutable;
          ".logseq/config/config.edn".text = mkIf (
            cfg.style != ""
          ) ''{:custom-css-url "@import ${cfg.style};"}'';
        }
        // util.map.folder {
          directory = settings;
          path = ".logseq/settings";
          extension = ".json";
          apply = text: { inherit text; } // mutable;
          replace = {
            placeholders = [ "@bg" ];
            values = [ config.lib.stylix.colors.base00 ];
          };
        };
    };
  };
}
