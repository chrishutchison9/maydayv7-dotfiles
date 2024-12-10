{
  config,
  util,
  pkgs,
  files,
  ...
}: let
  inherit (util.build) theme;
  inherit (config.lib.stylix) colors;
in {
  environment.systemPackages = with pkgs; [
    # Apps
    clipse
    custom.desktop-icons
    custom.kebihelp
    font-manager
    gnome-disk-utility
    hyprpicker
    mission-center
    nwg-displays
    nwg-drawer
    overskride
    qalculate-gtk
    remmina

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

  ## Essential Utilities
  services = {
    # Power
    power-profiles-daemon.enable = true;
    upower.enable = true;

    # Location
    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };
  };
  location.provider = "geoclue2";

  # Backlight
  user.groups = ["input" "video"];
  hardware.brillo.enable = true;

  user = {
    persist.directories = [
      ".config/nwg-displays"
      ".local/share/clipboard"
    ];

    homeConfig = {
      # Wallpaper Daemon
      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = false;
          splash = true;
        };
      };

      # Display Temperature
      services.gammastep = {
        enable = true;
        provider = "geoclue2";
        tray = true;
      };

      home.file = with files.hyprland; {
        # Application Drawer
        ".config/nwg-drawer/drawer.css".text = drawer;

        # Pyprland
        ".config/hypr/pyprland.toml".text = pypr;

        # Shaders
        ".config/hypr/shaders" = {
          source = "${pkgs.custom.hyprshaders}/share/hypr/shaders";
          recursive = true;
        };

        # Keybinds Viewer
        ".config/kebihelp.json".text = theme {
          inherit colors;
          inherit (config.stylix) fonts;
          file = kebihelp;
        };

        # Clipboard Manager
        ".config/clipse/config.json".text = clipse.config;
        ".config/clipse/theme.json".text = theme {
          inherit colors;
          file = clipse.theme;
        };
      };
    };
  };
}
