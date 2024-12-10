{
  config,
  util,
  pkgs,
  files,
  ...
}: let
  inherit (config.gui.launcher) terminal;
  nemo = pkgs.nemo-with-extensions;
in {
  ## File Manager Configuration
  services.dbus.packages = [nemo];
  environment.systemPackages = [nemo] ++ (with pkgs; [cinnamon-desktop file-roller]);

  user = {
    persist.directories = [".config/nemo" ".local/share/nemo"];
    homeConfig = {
      xdg.mimeApps.defaultApplications = util.build.mime files.xdg.mime {
        directory = ["nemo.desktop"];
      };

      dconf.settings = {
        "org/gtk/gtk4/settings/file-chooser".sort-directories-first = true;
        "org/nemo/search".search-reverse-sort = false;
        "org/nemo/desktop".show-desktop-icons = false;
        "org/nemo/plugins".disabled-actions = ["change-background.nemo_action"];

        "org/nemo/icon-view".captions = [
          "size"
          "date_modified"
          "none"
        ];

        "org/nemo/preferences" = {
          click-policy = "double";
          quick-renames-with-pause-in-between = true;
        };

        "org/nemo/preferences/menu-config" = {
          background-menu-open-in-terminal = false;
          selection-menu-open-in-terminal = false;
        };
      };

      home.file.".local/share/nemo/actions/terminal.nemo_action".text = ''
        [Nemo Action]
        Name=Open in Terminal
        Comment=Opens ${terminal} in the selected folder
        Exec=${terminal} --working-directory=%F
        Icon-Name=${terminal}
        Selection=any
        Extensions=dir;
        EscapeSpaces=true
      '';
    };
  };
}
