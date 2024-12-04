{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}:
with files; let
  inherit (config.lib.stylix) colors;
  exists = app: builtins.elem app config.apps.list;
  theme = import ../theme.nix pkgs;
in {
  apps.list = ["firefox"];
  gui.launcher.terminal = "kitty";
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # File Manager
  services.gnome.sushi.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  environment.systemPackages = with pkgs; [
    # Apps
    celluloid
    clipse
    custom.desktop-icons
    evince
    font-manager
    geany
    file-roller
    gnome-disk-utility
    hyprpicker
    custom.kebihelp
    lollypop
    mission-center
    nautilus
    nwg-displays
    nwg-drawer
    overskride
    playerctl
    qalculate-gtk
    remmina
    shotwell
    transmission_4-gtk

    # Utilities
    custom.hyprutils
    grim
    grimblast
    hyprkeys
    hyprshade
    pavucontrol
    pyprland
    slurp
    wev
    wl-clipboard
    wl-screenrec
    wlr-randr
    xfce.exo

    # Network Settings
    (gnome-control-center.overrideAttrs (old: {
      postInstall =
        old.postInstall
        + ''
          dir=$out/share/applications
          for panel in $dir/*
          do
            [ "$panel" = "$dir/gnome-network-panel.desktop" ] && continue
            [ "$panel" = "$dir/gnome-wifi-panel.desktop" ] && continue
            [ "$panel" = "$dir/gnome-wwan-panel.desktop" ] && continue
            [ "$panel" = "$dir/gnome-sharing-panel.desktop" ] && continue
            [ "$panel" = "$dir/gnome-wacom-panel.desktop" ] && continue
            rm "$panel"
          done
        '';
    }))
  ];

  user = {
    # Persisted Files
    persist.directories = [
      ".config/geany"
      ".config/mpv"
      ".config/nwg-displays"
      ".config/shotwell"
      ".local/share/clipboard"
      ".local/share/lollypop"
      ".local/share/nautilus"
      ".local/share/shotwell"
      ".cache/shotwell"
    ];

    homeConfig = {
      imports = util.map.modules.list ./.;

      # Default Applications
      xdg.mimeApps.defaultApplications = util.build.mime files.xdg.mime {
        audio = ["org.gnome.Lollypop.desktop"];
        directory = ["org.gnome.Nautilus.desktop"];
        image = ["org.gnome.Shotwell-Viewer.desktop"];
        magnet = ["transmission-gtk.desktop"];
        markdown = ["geany.desktop"];
        pdf = ["org.gnome.Evince.desktop"];
        text = ["geany.desktop"];
        video = ["io.github.celluloid_player.Celluloid.desktop"];
      };

      # App Environment
      wayland.windowManager.hyprland.settings.env = [
        # Screengrab
        "SLURP_ARGS, -dc ${colors.base0D}"

        # QT Apps
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
      ];

      # GTK Apps
      dconf.settings."org/gnome/desktop/wm/preferences" = {
        action-double-click-titlebar = "none";
        button-layout = "appmenu";
      };

      # Shortcuts
      wayland.windowManager.hyprland.settings.bind = let
        toggle = app: "pkill ${app} || uwsm app -u ${app}.scope -- ${app}";
        runOnce = app: "pgrep ${app} || uwsm app -u ${app}.scope -- ${app}";
      in [
        "$mod SHIFT, slash, exec, ${toggle "kebihelp"} show -a"
        "$mod, slash, exec, ulauncher-toggle"
        "$mod, A, exec, nwg-drawer"
        "$mod SHIFT, A, exec, hyprutils toggle panel"
        "$mod SHIFT, C, exec, ${runOnce "hyprpicker"} -arf hex"
        "$mod, D, exec, pypr toggle displays"
        "$mod, F, exec, nautilus"
        "$mod, N, exec, dunstctl history-pop"
        "$mod, T, exec, kitty"
        "$mod SHIFT, T, exec, pypr toggle term"
        ''$mod, V, exec, sh -c "hyprctl clients | grep 'class: clipse' || pypr show clip"''
        "$mod, W, exec, firefox"
        "$mod, Return, exec, ${runOnce "missioncenter"}"
        ", XF86Calculator, exec, qalculate-gtk"
        "$mod, Escape, exec, ${toggle "wlogout"} -p layer-shell"
      ];

      # Autostart
      wayland.windowManager.hyprland.settings.exec-once =
        ["uwsm finalize"]
        ++ (builtins.map (app: "uwsm app -t service -u ${util.build.until " " app}.service -- " + app) [
          "hyprutils daemon"

          # Application Drawer
          "nwg-drawer -r"

          # Clipboard Manager
          "clipse -listen"

          # Desktop Icons
          "dicons"

          # Pyprland
          "pypr"
        ]);

      # Utilities
      services.playerctld.enable = true;
      services.poweralertd.enable = true;

      # nix-community/home-manager/pull/5785
      systemd.user.services = {
        poweralertd.Unit.After = lib.mkForce ["graphical-session.target"];
        dunst.Unit.After = lib.mkForce ["graphical-session.target"];
      };

      # Wallpaper Daemon
      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = false;
          splash = true;
        };
      };

      # Terminal
      programs.kitty = {
        enable = true;
        themeFile = with theme; "${name-alt}-${variant-alt}";
        keybindings = {
          "ctrl+c" = "copy_or_interrupt";
          "kitty_mod+f" = "launch --allow-remote-control kitty +kitten search/search.py @active-kitty-window-id";
        };

        settings = {
          kitty_mod = "ctrl+shift";
          placement_strategy = "center";

          copy_on_select = "clipboard";
          scrollback_lines = 10000;

          enable_audio_bell = "no";
          visual_bell_duration = "0.1";
        };
      };

      wayland.windowManager.hyprland.settings.misc.swallow_regex = "^(kitty)$";
      stylix.targets.kitty = {
        enable = true;
        variant256Colors = true;
      };

      # Web Browser
      programs.firefox = {
        policies.ExtensionSettings = {
          name = with theme; "${name}-${variant}-${accent}";
          value = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/{d49033ac-8969-488c-afb0-5cdb73957f41}/latest.xpi";
          };
        };
      };

      # Media
      programs.mpv = {
        enable = true;
        defaultProfiles = ["gpu-hq"];
        scripts = [pkgs.mpvScripts.mpris];
      };

      # Notifications
      stylix.targets.dunst.enable = true;
      services.dunst = let
        ignore = {
          history_ignore = "yes";
          fullscreen = "show";
          highlight = "#${colors.base07}";
        };
      in {
        enable = true;
        iconTheme = theme.icons;
        settings = {
          global = {
            alignment = "center";
            corner_radius = 10;
            follow = "mouse";
            format = "<b>%s</b>\\n%b";
            frame_width = 1;
            horizontal_padding = 8;
            icon_corner_radius = 10;
            icon_position = "left";
            icon_theme = theme.icons.name;
            indicate_hidden = "yes";
            markup = "yes";
            max_icon_size = 64;
            mouse_left_click = "do_action";
            mouse_middle_click = "close_all";
            mouse_right_click = "close_current";
            offset = "5x5";
            padding = 8;
            plain_text = "no";
            progress_bar_corner_radius = 10;
            separator_height = 1;
            show_indicators = false;
            shrink = "no";
            transparency = 10;
            word_wrap = "yes";
          };

          fullscreen_delay.fullscreen = "delay";
          power = {appname = "poweralertd";} // ignore;
          utility = {appname = "utility";} // ignore;
        };
      };

      # Display Temperature
      services.gammastep = {
        enable = true;
        provider = "geoclue2";
        tray = true;
      };

      # File Manager
      dconf.settings = {
        "org/gtk/gtk4/settings/file-chooser".sort-directories-first = true;
        "org/gnome/nautilus/icon-view" = {
          captions = ["size" "date_modified" "none"];
          default-zoom-level = "medium";
        };

        "org/gnome/nautilus/preferences" = {
          click-policy = "single";
          default-folder-viewer = "icon-view";
          fts-enabled = true;
          search-filter-time-type = "last_modified";
          search-view = "list-view";
          show-create-link = true;
          show-delete-permanently = true;
        };
      };

      # Configuration Files
      home.file =
        {
          # Application Drawer
          ".config/nwg-drawer/drawer.css".text = hyprland.drawer;

          # Pyprland
          ".config/hypr/pyprland.toml".text = hyprland.pypr;

          # Shaders
          ".config/hypr/shaders" = {
            source = "${pkgs.custom.hyprshaders}/share/hypr/shaders";
            recursive = true;
          };

          # Keybinds Viewer
          ".config/kebihelp.json".text = util.build.theme {
            inherit colors;
            inherit (config.stylix) fonts;
            file = hyprland.kebihelp;
          };

          # Browser
          ".mozilla/firefox/default/chrome/userChrome.css".text = ''
            #TabsToolbar {
              -moz-window-dragging: no-drag;
            }
          '';

          # Clipboard Manager
          ".config/clipse/config.json".text = hyprland.clipse.config;
          ".config/clipse/theme.json".text = util.build.theme {
            inherit colors;
            file = hyprland.clipse.theme;
          };

          # Text Editor
          ".config/geany/geany.conf".text = geany.settings;
          ".config/geany/keybindings.conf".text = geany.keybindings;
          ".config/geany/colorschemes/theme.conf".source = with theme; "${pkgs.custom.geany-catppuccin}/share/geany/colorschemes/${name}-${variant}.conf";

          # Terminal
          ".config/kitty/search".source = pkgs.custom.kitty-search;
          ".config/xfce4/helpers.rc".text = ''
            TerminalEmulator=kitty
            TerminalEmulatorDismissed=true
          '';
        }
        ## 3rd Party Apps Configuration
        // {
          # Discord Chat
          ".config/vesktop/settings/quickCss.css" = with theme;
            lib.mkIf (exists "discord") {text = ''@import url("https://${name}.github.io/discord/dist/${name}-${variant}-${accent}.theme.css");'';};

          # Logseq Notes
          ".logseq/config.edn" = with theme;
            lib.mkIf (exists "notes") {text = ''{:custom-css-url "@import url('https://logseq.${name}.com/ctp-${variant}.css');"}'';};
        };

      # Code Editor
      programs.vscode = lib.mkIf (exists "vscode") {
        extensions = with pkgs; [
          vscode-extensions.catppuccin.catppuccin-vsc-icons
          (catppuccin-vsc.override {
            inherit (theme) accent;
            boldKeywords = true;
            italicComments = true;
            italicKeywords = true;
            extraBordersEnabled = false;
            workbenchMode = "default";
            bracketMode = "rainbow";
          })
        ];

        userSettings = with theme; {
          "workbench.colorTheme" = "${name-alt} ${variant-alt}";
          "workbench.iconTheme" = "${name}-${variant}";
          "terminal.external.linuxExec" = "kitty";
        };
      };
    };
  };
}
