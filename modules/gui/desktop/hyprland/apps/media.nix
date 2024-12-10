{
  util,
  pkgs,
  files,
  ...
}: {
  ## Media Configuration
  environment.systemPackages = with pkgs; [
    celluloid
    evince
    lollypop
    playerctl
    shotwell
    transmission_4-gtk
  ];

  user = {
    # Persisted Files
    persist.directories = [
      ".config/mpv"
      ".config/shotwell"
      ".local/share/lollypop"
      ".local/share/shotwell"
      ".cache/shotwell"
    ];

    homeConfig = {
      # Default Applications
      xdg.mimeApps.defaultApplications = util.build.mime files.xdg.mime {
        audio = ["org.gnome.Lollypop.desktop"];
        image = ["org.gnome.Shotwell-Viewer.desktop"];
        magnet = ["transmission-gtk.desktop"];
        pdf = ["org.gnome.Evince.desktop"];
        video = ["io.github.celluloid_player.Celluloid.desktop"];
      };

      # Media Player
      services.playerctld.enable = true;
      programs.mpv = {
        enable = true;
        defaultProfiles = ["gpu-hq"];
        scripts = [pkgs.mpvScripts.mpris];
      };
    };
  };
}
