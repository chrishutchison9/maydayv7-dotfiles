## Secrets Management ##
{
  config,
  inputs,
  ...
}: let
  inherit (config) util;
  inherit (config.flake) files;
in {
  flake.modules = {
    # System-Wide Secrets
    nixos.secrets = {
      config,
      pkgs,
      ...
    }: let
      path = files.path.gpg;
    in {
      imports = [inputs.sops.nixosModules.sops];

      config = {
        environment = {
          persist.directories = [path];
          systemPackages = [pkgs.sops];
        };

        sops = {
          gnupg.home = path;
          secrets = let
            directory = ./. + "/${config.networking.hostName}";
          in
            util.map.secrets {directory = ./.;}
            // (
              if (builtins.pathExists directory)
              then util.map.secrets {inherit directory;}
              else {}
            );
        };
      };
    };

    # Per-User Secrets
    homeManager.secrets = {config, ...}: {
      imports = [inputs.sops.homeManagerModules.sops];
      sops = {
        gnupg.home = "${config.home.homeDirectory}/.gnupg";
        secrets = let
          directory = ./user + "/${config.home.username}";
        in (
          if (builtins.pathExists directory)
          then util.map.secrets {inherit directory;}
          else {}
        );
      };
    };
  };
}
