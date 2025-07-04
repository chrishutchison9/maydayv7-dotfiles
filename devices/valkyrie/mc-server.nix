{ config, ... }:
{
  ## Minecraft Server
  specialisation.mc-server.configuration = {
    apps = {
      games = [ "mc-server" ];
      mc-server = {
        memory = 16;
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
