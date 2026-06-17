# Login Greeter
{inputs ? null, ...}: {
  nixos = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.noctalia-greeter.nixosModules.default];
    environment.persist.directories = ["/var/lib/noctalia-greeter"];
    programs.noctalia-greeter = {
      enable = true;
      settings.cursor = {
        theme = config.stylix.cursor.name;
        inherit (config.stylix.cursor) size package;
      };
    };
  };
}
