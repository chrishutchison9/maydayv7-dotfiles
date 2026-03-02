{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = builtins.elem "blockchain" config.hardware.support;
in
{
  ## Blockchain Support ##
  config = lib.mkIf enable {
    virtualisation.docker.enable = true;
    user.groups = [ "docker" ];
    environment = {
      persist.directories = [ "/var/lib/docker" ];
      systemPackages = with pkgs; [
        custom.fabric-ca
        hyperledger-fabric

        docker-compose
        nodejs
      ];
    };
  };
}
