{ config, ... }:
{
  ## Minecraft Server
  specialisation.minecraft.configuration = {
    system.nixos.label = "special.minecraft";
    apps = {
      games = [ "mc-server" ];
      mc-server = {
        type = "skyblock";
        memory = 16;
        vc-port = 24454;
        config = {
          motd = "My World";
          difficulty = "normal";
          gamemode = "survival";
          online-mode = false;
          server-ip = "0.0.0.0";
          server-port = 25565;
          spawn-protection = 0;
          allow-flight = true;
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
