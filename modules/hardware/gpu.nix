{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkForce
    mkIf
    mkEnableOption
    mkMerge
    mkOption
    types
    ;

  cfg = config.hardware.gpu;
  opt = options.hardware.gpu;
  mode = config.hardware.cpu.mode == "performance";
in
{
  ## GPU Configuration ##
  options.hardware.gpu = {
    enable = mkEnableOption "Discrete GPU Support";
    model = mkOption {
      description = "Discrete GPU Model";
      type = with types; nullOr (enum [ "nvidia" ]);
      default = null;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.model != null;
          message = opt.model.description + " must be set";
        }
      ];
    })

    (mkIf (cfg.enable && cfg.model == "nvidia") {
      services.xserver.videoDrivers = mkForce [ "nvidia" ];
      environment = {
        systemPackages = [ pkgs.btop-cuda ];
        variables = {
          "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
          "LIBVA_DRIVER_NAME" = "nvidia";
        };
      };

      boot = {
        blacklistedKernelModules = [ "nouveau" ];
        kernelModules = [
          "nvidia"
          "nvidia_drm"
          "nvidia_modeset"
          "nvidia_uvm"
        ];

        # Wayland Support
        kernelParams = [ "nvidia-drm.fbdev=1" ];

        extraModprobeConfig = ''
          # PAT Support
          options nvidia NVreg_UsePageAttributeTable=1

          # DDC/CI Support
          options nvidia NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100
        '';
      };

      hardware.nvidia = {
        modesetting.enable = mkForce true;
        nvidiaSettings = mkForce true;
        dynamicBoost.enable = true;
        powerManagement.enable = true;
        prime =
          with config.hardware.nvidia.prime;
          mkIf (amdgpuBusId != "" || intelBusId != "") {
            sync.enable = mkForce false;
            reverseSync.enable = mkForce mode;
            offload = {
              enable = mkForce (!mode);
              enableOffloadCmd = mkForce (!mode);
            };
          };
      };
    })

    (mkIf (!cfg.enable && cfg.model == "nvidia") {
      boot.blacklistedKernelModules = [
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
      ];
    })
  ];
}
