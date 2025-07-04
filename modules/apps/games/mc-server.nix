# ? # Run 'systemctl start minecraft-server-NAME' to start the server
# ? # Run 'echo COMMAND > /run/minecraft/NAME.stdin' to run commands
{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (builtins) attrValues elem toString;
  inherit (lib) mkIf mkOption types;
  cfg = config.apps.mc-server;
  dataDir = "/srv/minecraft";
  mem = toString cfg.memory;
in
{
  ## Minecraft Server ##
  imports = [ inputs.minecraft.nixosModules.minecraft-servers ];

  options.apps.mc-server = {
    memory = mkOption {
      description = "Memory (GB) allocated to server";
      type = types.int;
      default = 12;
    };

    config = mkOption {
      description = "Server Properties";
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf (elem "mc-server" config.apps.games) {
    environment.persist.directories = [ dataDir ];
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      inherit dataDir;
      managementSystem = {
        tmux.enable = false;
        systemd-socket.enable = true;
      };

      servers.fabric = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_6;
        serverProperties = cfg.config;
        jvmOpts = "-Xms${mem}G -Xmx${mem}G --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15";

        symlinks.mods = pkgs.linkFarmFromDrvs "mods" (attrValues {
          FabricAPI = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/F5TVHWcE/fabric-api-0.128.2%2B1.21.6.jar";
            sha512 = "sha512-ttDsCuxABpyx+iFZwSbQJ9f5Xj9iYKPojr6cR/PLcW0RcK+OLk/z1BCM5e6upwACqIlUdXg3TU1t+kV1XplDHg==";
          };
          Lithium = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/XWGBHYcB/lithium-fabric-0.17.0%2Bmc1.21.6.jar";
            sha512 = "sha512-qNaotprisQ3Qz4+BSSYNW9vSWDFHRiutAzgAFO3YV4Upcrln2X32lygzPYg2senbiZdxLqJjZd24oFuMhFxlNA==";
          };
          Krypton = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/neW85eWt/krypton-0.2.9.jar";
            sha512 = "sha512-LiMEsbF+z5V4Ou6S4m5Uyb+tMlx9/NFN7r+YkSZuspM9sA/3eIXKoIP6qW8JxVHrVvk89zs1d4nLMe2tSTn/6w==";
          };
          FerriteCore = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/CtMpt7Jr/ferritecore-8.0.0-fabric.jar";
            sha512 = "sha512-ExuC0dNm8JZkNb/LOMNi1gTWjs8wwQbTGmJhv8hoyjqCQluz+uuqLl6hfY7tXJKEOBDrLfR5Dy+LHmwb3Jt3RQ==";
          };
          ScalableLux = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/PQLHDg2Q/ScalableLux-0.1.5%2Bfabric.e4acdcb-all.jar";
            sha512 = "sha512-7I+rw7+ZH7y+Bkwel97T5w8UWofkNgViQcux4UxX6p9Z7zEvJMIFFgzL2kP2k+BdZSt/Gapx9zDK7Du19/eCCg==";
          };
          C2ME = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/VSNURh3q/versions/y6wodInu/c2me-fabric-mc1.21.6-0.3.4%2Balpha.0.42.jar";
            sha512 = "sha512-PVOx3YSgNrX7kfFaC8U45vKkrCB8R0mrGrh0lyF4vCzCDx/hwvjAjp7vCma09rLeIjFNlNBJirzwJSGd/GnXVg==";
          };
          SkinRestorer = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/ghrZDhGW/versions/fs7VElhv/skinrestorer-2.3.5%2B1.21.6-fabric.jar";
            sha512 = "sha512-xQq0b3XrbvJ4Af5YpMMn4cVlNYSUtgvMsQxCDSTXn1Qw4L/DCeBvvl1Cde9FKEEoZ9VsRHzJF6deYfNQf0Wp6w==";
          };
        });

        files = {
          "world/datapacks/veinminer.zip" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/OhduvhIc/versions/gZ4v72II/veinminer-1.3.1.zip";
            sha512 = "sha512-1BoWu/plQA+QqEGyDIqQm+lTcp/08R2Ztb+3EjuUwS31sgQThsy4cLCDfCx4o5z2Wvh5KC8D5QaJQjQ5Rzw30A==";
          };
          "world/datapacks/veinminer-enchant.zip" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/4sP0LXxp/versions/3D1S0vgH/Veinminer-Enchantment-1.2.3.zip";
            sha512 = "sha512-zQFNtwr/WDgozXRRHA8ObFRjD/ciJmgiAJNgYkL2oUQmUhRIHbPuzyuEFDdiA4OlFf64lKCdegWmdZwsjJDs4Q==";
          };
        };
      };
    };
  };
}
