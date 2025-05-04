{
  system = "x86_64-linux";
  name = "valkyrie";
  description = "PC - ASUS ROG Zephyrus G14";

  timezone = "Asia/Kolkata";
  locale = "IN";

  kernel = "xanmod_stable";
  kernelModules = [
    "nvme"
    "thunderbolt"
  ];

  imports = [ ./drivers.nix ];
  hardware = {
    boot = "secure";
    filesystem = "advanced";
    modules = [ "asus-zephyrus-ga402x-nvidia" ];
    gpu = "nvidia";
    cpu = {
      cores = 8;
      mode = "performance";
    };

    support = [
      "laptop"
      "mobile"
      "printer"
      "virtualisation"
    ];

    vm = {
      android.enable = false;
      vfio = "setup";
      passthrough = [
        "10de:28e0"
        "10de:22be"
      ];
    };
  };

  apps = {
    wine.utilities = true;
    games = [ "osu" ];
    list = [
      "discord"
      "firefox"
      "games"
      "git"
      "media"
      "notes"
      "office"
      "spotify"
      "vscode"
      "wine"
    ];
  };

  shell = {
    prompt = true;
    utilities = true;
  };

  nix = {
    index = true;
    tools = true;
  };

  gui = {
    desktop = "hyprland";
    display = "eDP-1";
    wallpaper = "Quasar";
    fancy = true;
  };

  # User V7
  user = {
    name = "v7";
    description = "V 7";
    uid = 1000;
    shell = "zsh";
    shells = [ "bash" ];
    groups = [
      "wheel"
      "keys"
      "systemd-journal"
    ];
  };
}
