## Windows VM
# ? # Run 'virsh -c qemu:///system start windows'
{inputs}: {
  nixos = {pkgs, ...}: {
    imports = [inputs.nixvirt.nixosModules.default];
    virtualisation.libvirt = {
      enable = true;
      package = pkgs.libvirt;
      connections."qemu:///system".domains = [
        {
          definition = ./windows.xml;
          active = null;
        }
      ];
    };
  };
}
