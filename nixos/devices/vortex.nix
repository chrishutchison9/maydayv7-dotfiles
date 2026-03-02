{
  system = "x86_64-linux";
  name = "vortex";
  description = "PC - Dell Inspiron 15 5000";

  timezone = "Asia/Kolkata";
  locale = "IN";

  kernel = "xanmod";
  kernelModules = [
    "nvme"
    "thunderbolt"
  ];

  imports = [ { services.fwupd.enable = true; } ];
  hardware = {
    boot = "secure";
    fs.scheme = "advanced";
    modules = [ "dell-inspiron-5509" ];
    cpu = {
      model = "intel";
      cores = 8;
    };

    support = [
      "laptop"
      "mobile"
      "printer"
      "virtualisation"
    ];
  };

  apps = {
    wine.utilities = true;
    list = [
      "discord"
      "firefox"
      "git"
      "internet"
      "office"
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
    wallpaper = "Thread";
    fancy = true;
  };

  # User V7
  user = {
    name = "v7";
    description = "V 7";
    shell = "zsh";
    shells = [ "bash" ];
    groups = [
      "wheel"
      "keys"
    ];
  };
}
