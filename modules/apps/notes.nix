{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}:
with files.logseq; let
  enable = builtins.elem "notes" config.apps.list;
in {
  ## Logseq Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = [pkgs.logseq];

    user = {
      persist.directories = [".logseq" ".config/Logseq"];
      homeConfig.home.file =
        {
          ".config/logseq/configs.edn".text = ''{:window/native-titlebar? true}'';
          ".logseq/preferences.json".text = prefs;
        }
        // util.map.folder {
          directory = settings;
          path = ".logseq/settings";
          extension = ".json";
          apply = text: {inherit text;};
          replace = {
            placeholders = ["@bg"];
            values = [config.lib.stylix.colors.base00];
          };
        };
    };
  };
}
