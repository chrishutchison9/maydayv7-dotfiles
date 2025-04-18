{
  system = "x86_64-linux";
  name = "valkyrie";
  description = "PC - ASUS ROG Zephyrus G14";

  timezone = "Asia/Kolkata";
  locale = "IN";

  kernel = "xanmod_stable";
  kernelModules = ["nvme" "thunderbolt"];

  imports = [./drivers.nix];
  hardware = {
    boot = "secure";
    filesystem = "advanced";
    support = ["laptop" "mobile" "printer" "virtualisation"];
    modules = ["asus-zephyrus-ga402x-nvidia"];
    gpu = "nvidia";
    cpu = {
      cores = 8;
      mode = "performance";
    };

    vm = {
      vfio = "setup";
      passthrough = ["10de:28e0" "10de:22be"];
      android.enable = false;
    };
  };

  apps = {
    wine.utilities = true;
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
    groups = ["wheel" "keys" "systemd-journal"];
    uid = 1000;
    shell = "zsh";
    shells = ["bash"];
  };
}
