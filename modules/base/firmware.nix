{
  lib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [ inputs.gaming.nixosModules.pipewireLowLatency ];

  ## Device Firmware ##
  config = {
    # Drivers
    security.rtkit.enable = true;
    hardware = {
      graphics.enable = true;
      enableRedistributableFirmware = true;
    };

    # Audio
    environment.systemPackages = [ pkgs.alsa-utils ];
    services.pulseaudio.enable = mkForce false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      lowLatency = {
        enable = true;
        quantum = 64;
        rate = 48000;
      };
    };

    # Network Settings
    user.groups = [ "networkmanager" ];
    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };

    # Memory
    systemd.oomd.enable = false;
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 15;
    };

    ## Encryption
    # GPG
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # SSH
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = mkForce "no";
      };

      hostKeys = [
        {
          comment = "Host SSH Key";
          bits = 4096;
          type = "ed25519";
          path = "/etc/ssh/ssh_key";
        }
      ];
    };

    # Persisted Files
    user.homeConfig.home.persist.directories = [
      {
        directory = ".gnupg";
        mode = "0700";
      }
    ];

    environment.persist.directories = [
      "/etc/NetworkManager"
      "/etc/ssh"
      "/var/lib/alsa"
      "/var/lib/bluetooth"
    ];
  };
}
