## VFIO Configuration ##
_: {
  flake.modules.nixos.vfio = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.virt.vfio;
    inherit (config.hardware.cpu) model;
    shmSize = 64; # KVMFR Shared Memory size
  in {
    options.virt.vfio = {
      setup = lib.mkEnableOption "VFIO Setup Mode";
      passthrough = lib.mkOption {
        description = "PCI Device IDs for VFIO Passthrough";
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [
          "10de:28e0" # Graphics
          "10de:22be" # Audio
        ];
      };

      isolate = lib.mkOption {
        description = "Host CPU set to isolate for pinned guest vCPUs";
        type = lib.types.str;
        default = "";
        example = "2-4,10-12";
      };

      hugepages = lib.mkOption {
        description = "Number of 1 GiB hugepages to reserve for guest";
        type = lib.types.ints.unsigned;
        default = 0;
        example = 16;
      };
    };

    config = lib.mkMerge [
      (lib.mkIf cfg.setup {
        specialisation.vfio.configuration = {
          system.nixos.label = "special.vfio";
          virt.vfio.setup = lib.mkForce false;
        };
      })

      (lib.mkIf (!cfg.setup) {
        # Disable GPU
        hardware.gpu.enable = lib.mkForce false;

        boot = {
          kernelParams =
            [
              "iommu=pt"
              "${model}_iommu=on"
              "kvm.ignore_msrs=1"
              "kvm.report_ignored_msrs=0"
              ("vfio-pci.ids=" + builtins.concatStringsSep "," cfg.passthrough)
            ]
            ++ lib.optionals (cfg.isolate != "") [
              "isolcpus=${cfg.isolate}"
              "nohz_full=${cfg.isolate}"
              "rcu_nocbs=${cfg.isolate}"
            ]
            ++ lib.optionals (cfg.hugepages > 0) [
              "default_hugepagesz=1G"
              "hugepagesz=1G"
              "hugepages=${toString cfg.hugepages}"
            ];

          initrd.kernelModules = [
            "vfio"
            "vfio_pci"
            "vfio_iommu_type1"
          ];

          # KVMFR
          extraModulePackages = [config.boot.kernelPackages.kvmfr];
          kernelModules = ["kvmfr"];
          extraModprobeConfig = "options kvmfr static_size_mb=${toString shmSize}";
        };

        # Looking Glass
        environment.systemPackages = [pkgs.looking-glass-client];
        services.udev.extraRules = ''
          SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", MODE="0660", GROUP="kvm", TAG+="systemd"
        '';

        users.users.qemu-libvirtd.extraGroups = ["kvm"];
        virtualisation.libvirtd.qemu.verbatimConfig = ''
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/userfaultfd",
            "/dev/kvmfr0"
          ]
        '';

        environment.etc."looking-glass-client.ini".text = lib.generators.toINI {} {
          app = {
            renderer = "egl";
            shmFile = "/dev/kvmfr0";
          };
          win = {
            title = "Virtual Machine";
            autoResize = "yes";
            borderless = "no";
            dontUpscale = "yes";
            fullScreen = "no";
            keepAspect = "yes";
            maximize = "no";
            noScreensaver = "yes";
            quickSplash = "yes";
            uiSize = 16;
          };
          egl = {
            scale = 2;
            multisample = "yes";
            vsync = "yes";
          };
          input = {
            autoCapture = "yes";
            grabKeyboardOnFocus = "yes";
            rawMouse = "yes";
            releaseKeysOnFocusLoss = "yes";
          };
          spice = {
            enable = "yes";
            clipboard = "yes";
          };
          wayland = {
            warpSupport = "yes";
            fractionScale = "no";
          };
        };
      })
    ];
  };
}
