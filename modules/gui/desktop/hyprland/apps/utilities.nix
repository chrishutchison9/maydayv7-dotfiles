{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}:
let
  inherit (lib) getExe;
  inherit (config.lib.stylix) colors;
in
{
  environment.systemPackages = with pkgs; [
    # Apps
    clipse
    custom.kebihelp
    font-manager
    gnome-clocks
    gnome-disk-utility
    hyprpicker
    hyprworld.hyprshell
    nwg-displays
    nwg-drawer
    overskride
    qalculate-gtk
    remmina
    resources
    smile

    # Utilities
    custom.hyprutils
    grim
    grimblast
    hyprkeys
    hyprshade
    hyprsunset
    pavucontrol
    pyprland
    slurp
    waycorner
    wev
    wlclock
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

  ## Essential Utilities
  # Power
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  # Backlight
  hardware.brillo.enable = true;
  user.groups = [
    "input"
    "video"
  ];

  user = {
    persist.directories = [
      ".config/nwg-displays"
      ".local/share/hyprshell"
    ];

    homeConfig = {
      services = {
        # Wallpaper Daemon
        hyprpaper = {
          enable = true;
          settings = {
            ipc = false;
            splash = true;
          };
        };

        # Display Temperature
        hyprsunset = {
          enable = true;
          extraArgs = [ "--identity" ];
          transitions = {
            sunrise = {
              calendar = "*-*-* 07:00:00";
              requests = [
                [
                  "temperature"
                  "6000"
                ]
                [ "identity" ]
              ];
            };
            sunset = {
              calendar = "*-*-* 19:00:00";
              requests = [
                [
                  "temperature"
                  "4000"
                ]
              ];
            };
          };
        };
      };

      systemd.user.services =
        let
          target = [ "graphical-session.target" ];
          run = about: command: {
            Install.WantedBy = target;
            Unit = {
              Description = about;
              After = target;
            };
            Service = {
              Restart = "always";
              RestartSec = 1;
              ExecStart = command;
            };
          };
        in
        {
          hyprshell = run "Launcher" "${getExe pkgs.hyprworld.hyprshell} run";
          waycorner = run "Hot Corners" (getExe pkgs.waycorner);
          wlclock =
            with colors;
            run "Desktop Clock" "${getExe pkgs.wlclock} --layer bottom --exclusive-zone true --position top-right --margin 10 --size 300 --corner-radius 10 --border-size 2 --hand-width 7 --marking-width 3 --background-colour #${base00}4d --clock-colour #${base0D} --border-colour #${base00}";
        };

      # Network Settings
      xdg.desktopEntries."org.gnome.Settings" = {
        name = "Network Settings";
        comment = "Gnome Control Center";
        icon = "org.gnome.Settings";
        exec = "env XDG_CURRENT_DESKTOP=gnome gnome-control-center";
        categories = [ "X-Preferences" ];
        terminal = false;
      };

      home.file =
        with files.hyprland;
        let
          build =
            file:
            util.build.theme {
              inherit colors file;
              inherit (config.stylix) fonts;
            };
        in
        {
          # Application Drawer
          ".config/nwg-drawer/drawer.css".text = drawer;

          # Pyprland
          ".config/hypr/pyprland.toml".text = pypr;

          # Keybinds Viewer
          ".config/kebihelp.json".text = build kebihelp;

          # Hot Corners
          ".config/waycorner/config.toml".text = waycorner;

          # Launcher
          ".config/hyprshell/config.ron".text = hyprshell.config;
          ".config/hyprshell/styles.css".text = build hyprshell.style;

          # Shaders
          ".config/hypr/shaders" = {
            source = files.proprietary.shaders.path;
            recursive = true;
          };
        };
    };
  };
}
