### Devices

The `devices` directory contains the core definitions for multiple PCs and various other devices.
To add a device, create a configuration file matching the device's `hostname`.
Define the configuration using options from the [`modules`](../modules/README.md) directory, or add your own modules using the `imports` keyword.
Optionally, add user-specific configuration in [`users`](../users/README.md).
Then, run the command `nixos-rebuild switch --flake .#HOSTNAME` and let Nix do all the work for you!

#### Additional Options

These are the options that can be used in addition to the ones exposed by the [`modules`](../modules/README.md):

- `imports`: Additional Configuration Files to import - Ex. `[ ./hardware-configuration.nix ]`
- `description`: System Description (to add to `config.system.name`)
- `timezone`: System Time Zone - Ex. `"Asia/Kolkata"`
- `locale`: Default Locale - Ex. `"IN"`
- `kernel`: Linux Kernel to use (from `pkgs.linuxKernel.packages.linux_${kernel}`) - Ex. `zfs`
- `kernelModules`: Additional Kernel Modules (added to `config.boot.initrd.availableKernelModules`) - Ex. `[ "nvme" ]`
- `user` or `users` (--> `config.user.settings`): Used to specify Device User/Multiple Users per Device - Ex. `users = [ { name "1"; } { name = "2"; } ]`
- `update`: Enable Automatic System Upgrades - Ex. `weekly`
