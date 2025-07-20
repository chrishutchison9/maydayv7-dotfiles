{ config, ... }:
{
  ## Minecraft Server
  specialisation.minecraft.configuration = {
    system.nixos.label = "special.minecraft";
    apps = {
      games = [ "mc-server" ];
      mc-server = {
        memory = 16;
        vc-port = 24454;
        config = {
          motd = "My World";
          gamemode = "survival";
          difficulty = "normal";
          online-mode = false;
          server-port = 25565;
          server-ip = "0.0.0.0";
        };
      };
    };

    # VPN Tunnel
    environment.persist.directories = [ "/var/lib/tailscale" ];
    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = config.sops.secrets."tailscale.secret".path;
    };
  };
}
