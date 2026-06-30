## Base Configuration ##
_: {
  flake.modules = {
    nixos.base = {
      config,
      options,
      pkgs,
      lib,
      ...
    }: let
      inherit (builtins) attrNames map;
      inherit
        (lib)
        hasPrefix
        mkIf
        mkOption
        optionals
        removePrefix
        types
        ;
      cfg = config.system;
    in {
      options.system = {
        kernel = mkOption {
          description = "Linux Kernel Variant to be used";
          default = "lts";
          type = types.enum (
            ["lts"] ++ (map (name: removePrefix "linux_" name) (attrNames pkgs.linuxKernel.kernels))
          );
        };

        kernelModules = mkOption {
          description = "Linux Kernel Modules to load";
          type = with types; listOf str;
          default = [];
        };
      };

      config = {
        # System version
        system.stateVersion = lib.mkDefault lib.trivial.release;

        # Kernel Configuration
        boot = {
          kernelPackages =
            if (cfg.kernel == "lts")
            then options.boot.kernelPackages.default
            else pkgs.linuxKernel.packages."${"linux_" + cfg.kernel}";

          initrd.availableKernelModules = optionals (cfg.kernelModules != []) (
            cfg.kernelModules
            ++ [
              "ahci"
              "sd_mod"
              "usbhid"
              "usb_storage"
              "xhci_pci"
            ]
          );
        };

        environment = {
          etc."specialisation" =
            mkIf (hasPrefix "special." cfg.nixos.label)
            {text = removePrefix "special." cfg.nixos.label;};

          # Essential Utilities
          systemPackages = with pkgs; [
            custom.os
            cryptsetup
            file
            inxi
            killall
            man-pages
            mkpasswd
            ntfsprogs
            parted
            pciutils
            rsync
            sdparm
            smartmontools
            unrar
            unzip
            usbutils
            wget
            alsa-utils
          ];
        };

        # Console
        console = {
          earlySetup = true;
          packages = [pkgs.terminus_font];
          font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
        };

        # Drivers
        security.rtkit.enable = true;
        hardware = {
          graphics.enable = true;
          enableRedistributableFirmware = true;
        };

        services.pulseaudio.enable = lib.mkForce false;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

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

        environment.persist.directories = [
          "/etc/NetworkManager"
          "/var/lib/alsa"
          "/var/lib/bluetooth"
        ];
      };
    };

    homeManager.base = {lib, ...}: {
      home.stateVersion = lib.mkDefault lib.trivial.release;
    };
  };
}
