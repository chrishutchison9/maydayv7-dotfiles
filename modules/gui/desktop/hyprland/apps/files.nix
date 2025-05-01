{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}: let
  inherit (lib) hm getExe getExe' replaceStrings;
  inherit (config.gui) icons;
  terminal = "kitty";
  nemo = pkgs.nemo-with-extensions;
in {
  ## File Manager Configuration
  services.dbus.packages = [nemo];
  environment.systemPackages =
    [nemo]
    ++ (with pkgs; [
      cinnamon-desktop
      bulky
      file-roller
      lxqt.pcmanfm-qt
    ]);

  user = {
    persist.directories = [
      ".config/nemo"
      ".local/share/nemo"
      ".config/pcmanfm-qt"
    ];

    homeConfig = {
      xdg.mimeApps.defaultApplications = util.build.mime {
        archive = ["org.gnome.FileRoller.desktop"];
        directory = ["nemo.desktop"];
      };

      # Settings
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

      home = {
        # Bulk Renamer
        activation.nemo-rename = hm.dag.entryAfter ["writeBoundary"] ''
          if [[ -v DBUS_SESSION_BUS_ADDRESS ]]
          then
            export DCONF_DBUS_RUN_SESSION=""
          else
            export DCONF_DBUS_RUN_SESSION="${getExe' pkgs.dbus "dbus-run-session"} --dbus-daemon=${getExe' pkgs.dbus "dbus-daemon"}"
          fi

          run $DCONF_DBUS_RUN_SESSION ${getExe pkgs.dconf} write /org/nemo/preferences/bulk-rename-tool "b'bulky'"
          unset DCONF_DBUS_RUN_SESSION
        '';

        file = {
          # Open in Terminal
          ".local/share/nemo/actions/terminal.nemo_action".text = ''
            [Nemo Action]
            Name=Open in Terminal
            Comment=Opens ${terminal} in the selected folder
            Exec=${terminal} --working-directory=%F
            Icon-Name=${terminal}
            Selection=any
            Extensions=dir;
            EscapeSpaces=true
          '';

          # Desktop Icons
          ".config/pcmanfm-qt/default/settings.conf".text =
            replaceStrings [
              "@icon"
              "@font"
              "@terminal"
              "@wallpaper"
              "@archiver"
            ]
            [
              icons.name
              config.stylix.fonts.sansSerif.name
              terminal
              (builtins.toString files.images.transparent)
              "file-roller"
            ]
            files.hyprland.pcmanfm;
        };
      };
    };
  };
}
