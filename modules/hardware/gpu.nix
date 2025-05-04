{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkForce
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.hardware;
in
{
  options.hardware.gpu = mkOption {
    description = "Discrete GPU Support";
    type = with types; nullOr (enum [ "nvidia" ]);
    default = null;
  };

  config = mkMerge [
    (mkIf (cfg.gpu == "nvidia") {
      services.xserver.videoDrivers = mkForce [ "nvidia" ];
      environment.variables = {
        "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
        "LIBVA_DRIVER_NAME" = "nvidia";
      };

      boot = {
        blacklistedKernelModules = [ "nouveau" ];
        kernelModules = [
          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm.fbdev=1" # Wayland Support
          "NVreg_UsePageAttributeTable=1" # PAT Support
          "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100" # DDC/CI Support
        ];
      };

      hardware.nvidia =
        let
          enable = cfg.vm.vfio != "on";
          mode = cfg.cpu.mode == "performance";
        in
        {
          modesetting.enable = mkForce true;
          nvidiaSettings = mkForce true;
          dynamicBoost = { inherit enable; };
          powerManagement = { inherit enable; };
          prime =
            with cfg.nvidia.prime;
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
  ];
}
