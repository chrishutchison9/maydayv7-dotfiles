{
  config,
  lib,
  ...
}:
let
  inherit (lib) hasPrefix mkIf;
in
{
  # ! # https://gitlab.freedesktop.org/drm/amd/-/issues/3388
  boot.kernelParams = mkIf (config.hardware.cpu.mode == "performance") [ "amdgpu.dcdebugmask=0x10" ];

  # ! # https://github.com/NixOS/nixpkgs/issues/429624
  # ! # Remove after driver update (25.11)
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "580.65.06";
    sha256_64bit = "sha256-BLEIZ69YXnZc+/3POe1fS9ESN1vrqwFy6qGHxqpQJP8=";
    openSha256 = "sha256-BKe6LQ1ZSrHUOSoV6UCksUE0+TIa0WcCHZv4lagfIgA=";
    settingsSha256 = "sha256-9PWmj9qG/Ms8Ol5vLQD3Dlhuw4iaFtVHNC0hSyMCU24=";
    usePersistenced = false;
  };

  services = {
    fwupd.enable = true;

    # Remap Keys
    udev.extraHwdb = ''
      evdev:name:Asus Keyboard:*
        KEYBOARD_KEY_7003f=print # F6 -> PrtSc Key
    '';
  };

  # Development
  networking.firewall = {
    allowedUDPPorts = [ 7777 ];
    allowedTCPPorts = [ 7777 ];
  };

  # ASUS Software
  services.asusd = {
    enable = true;
    enableUserService = true;
    asusdConfig.text = builtins.readFile ./settings/asusd.ron;
    auraConfigs."19b6".text = builtins.readFile ./settings/aura.ron;
  };

  user = {
    persist.directories = [ ".config/rog" ];
    homeConfig = {
      wayland.windowManager.hyprland.settings.bindl = mkIf (hasPrefix "hyprland" config.gui.desktop) [
        ", XF86Launch3, exec, asusctl led-mode -n"
        ", XF86Launch4, exec, asusctl profile -n"
      ];

      dconf.settings = mkIf (hasPrefix "gnome" config.gui.desktop) {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          binding = "Launch3";
          command = "asusctl led-mode -n";
          name = "Keyboard Mode";
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
          binding = "Launch4";
          command = "asusctl profile -n";
          name = "Fan Control";
        };
      };
    };
  };
}
