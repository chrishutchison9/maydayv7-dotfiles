## Device Firmware ##
_: {
  flake.modules.nixos.mobile = {pkgs, ...}: {
    users.groups.adbusers = {};
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [
      android-tools
      scrcpy

      ifuse
      libimobiledevice
    ];
  };
}
