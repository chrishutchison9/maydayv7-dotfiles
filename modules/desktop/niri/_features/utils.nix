## Utilities
_: {
  nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # Screen Mirroring
      wl-mirror

      # XWayland Support
      xwayland-satellite
    ];
  };
}
