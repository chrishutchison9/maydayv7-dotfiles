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
  inherit (builtins)
    attrValues
    elem
    isInt
    toString
    ;
  inherit (lib)
    mkIf
    mkOption
    types
    ;
  inherit (pkgs) fetchurl linkFarmFromDrvs;

  cfg = config.apps.mc-server;
  mem = toString cfg.memory;
  vc = isInt cfg.vc-port;
  dataDir = "/srv/minecraft";
in
{
  ## Minecraft Server ##
  imports = [ inputs.minecraft.nixosModules.minecraft-servers ];

  options.apps.mc-server = {
    type = mkOption {
      description = "Server Type";
      type = types.enum [
        "fabric"
        "skyblock"
      ];
      default = "default";
    };

    config = mkOption {
      description = "Server Properties";
      type = types.attrs;
      default = { };
    };

    memory = mkOption {
      description = "Memory (GB) allocated to Server";
      type = types.int;
      default = 12;
    };

    vc-port = mkOption {
      description = "Port for Simple Voice Chat";
      type = with types; nullOr int;
      default = null;
    };
  };

  config = mkIf (elem "mc-server" config.apps.games) {
    hardware.fs.persist.directories = [ dataDir ];
    networking.firewall.allowedUDPPorts = mkIf vc [ cfg.vc-port ];
    services.minecraft-servers =
      let
        shared = {
          autoStart = true;
          serverProperties = cfg.config;
          jvmOpts = "-Xms${mem}G -Xmx${mem}G --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15";
        };
      in
      {
        enable = true;
        inherit dataDir;
        eula = true;
        openFirewall = true;
        managementSystem = {
          tmux.enable = false;
          systemd-socket.enable = true;
        };

        servers = {
          fabric = shared // {
            enable = cfg.type == "fabric";
            package = pkgs.fabricServers.fabric-1_21_10;
            symlinks.mods = linkFarmFromDrvs "mods" (
              attrValues (
                {
                  # Server
                  FabricAPI = fetchurl {
                    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/lxeiLRwe/fabric-api-0.136.0%2B1.21.10.jar";
                    sha256 = "sha256-ADKAQNMSXhDUF/Fviupkr3JxmH6RFVRLuwvjK7PQV5c=";
                  };
                  Lithium = fetchurl {
                    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/oGKQMdyZ/lithium-fabric-0.20.0%2Bmc1.21.10.jar";
                    sha256 = "sha256-567yN1D2eJgsAMQhjWIFljqZRVRFfCoWvZgY41IQAEs=";
                  };
                  Krypton = fetchurl {
                    url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/O9LmWYR7/krypton-0.2.10.jar";
                    sha256 = "sha256-lCkdVpCgztf+fafzgP29y+A82sitQiegN4Zrp0Ve/4s=";
                  };
                  FerriteCore = fetchurl {
                    url = "https://cdn.modrinth.com/data/uXXizFIs/versions/CtMpt7Jr/ferritecore-8.0.0-fabric.jar";
                    sha256 = "sha256-K5C/AMKlgIw8U5cSpVaRGR+HFtW/pu76ujXpxMWijuo=";
                  };
                  ScalableLux = fetchurl {
                    url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/PV9KcrYQ/ScalableLux-0.1.6%2Bfabric.c25518a-all.jar";
                    sha256 = "sha256-ekpzcThhg8dVUjtWtVolHXWsLCP0Cvik8PijNbBdT8I=";
                  };
                  C2ME = fetchurl {
                    url = "https://cdn.modrinth.com/data/VSNURh3q/versions/eY3dbqLu/c2me-fabric-mc1.21.10-0.3.5.0.0.jar";
                    sha256 = "sha256-PZxX7IE3Zc+zsQrMc/LdI1jpUC9l/ov7z334OucWpgA=";
                  };

                  PlayerRoles = fetchurl {
                    url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/Qi5eDlej/player-roles-1.7.0.jar";
                    sha256 = "sha256-+0nk/J2W3hVDdkKlZRHY4dBde3aF8e8Y1SPFOgDWNb0=";
                  };
                  SkinRestorer = fetchurl {
                    url = "https://cdn.modrinth.com/data/ghrZDhGW/versions/MKWfnXfO/skinrestorer-2.4.3%2B1.21.9-fabric.jar";
                    sha256 = "sha256-ypyDuX94HyUPlUI4CrFc0Pc01lUQXgYPqP/axaCi6Hc=";
                  };
                  Silk = fetchurl {
                    url = "https://cdn.modrinth.com/data/aTaCgKLW/versions/2OisNxPN/silk-all-1.11.4.jar";
                    sha256 = "sha256-C2VcLfFGweGOO+Xi1mOTkETX3NpoEdSz+9kYmEIDDv0=";
                  };
                  FabricKotlin = fetchurl {
                    url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/LcgnDDmT/fabric-language-kotlin-1.13.7%2Bkotlin.2.2.21.jar";
                    sha256 = "sha256-d5UZY+3V19N+5PF0431GqHHkW5c0JvO0nWclyBm0uPI=";
                  };
                  Veinminer = fetchurl {
                    url = "https://cdn.modrinth.com/data/OhduvhIc/versions/lCVEKyxE/veinminer-fabric-2.5.0.jar";
                    sha256 = "sha256-13PbmxgTfM+WkQht7hsHrkEImXgTeBUpeKOcGtE/cOI=";
                  };
                  VeinminerEnchant = fetchurl {
                    url = "https://cdn.modrinth.com/data/4sP0LXxp/versions/h5oKcjvq/veinminer-enchant-2.3.0.jar";
                    sha256 = "sha256-NvGnsY9nfI+IMy2+Ljr1IahMqim9xOsRgojaFKWk/xQ=";
                  };

                  # Client and Server
                  Jade = fetchurl {
                    url = "https://cdn.modrinth.com/data/nvQzSEkH/versions/qC0qUqL5/Jade-1.21.9-Fabric-20.0.5.jar";
                    sha256 = "sha256-HZfvnnYeRgbgQROdq6v9U7fnx1MhNaseaedNJPJpNxE=";
                  };
                }
                // (
                  if vc then
                    {
                      SimpleVC = fetchurl {
                        url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/BjR2lc4k/voicechat-fabric-1.21.10-2.6.6.jar";
                        sha256 = "sha256-yC5pMBLsi4BnUq4CxTfwe4MGTqoBg04ZaRrsBC3Ds3Y=";
                      };
                    }
                  else
                    { }
                )
              )
            );
          };

          # Ozone Skyblock Reborn 2
          skyblock =
            let
              inherit (inputs.minecraft.lib) collectFilesAt;
              modpack = pkgs.fetchzip {
                url = "https://mediafilez.forgecdn.net/files/7165/375/OSR2%201.1.5%20-%20Server.zip";
                sha256 = "sha256-5oVl3zcQQ6ad6Yx79+9m7K5wHzFVgK1zlEXE4NAuOfQ=";
              };
            in
            shared
            // {
              enable = cfg.type == "skyblock";
              package = pkgs.neoforgeServers.neoforge-1_21_1;
              files = (collectFilesAt modpack "config") // (collectFilesAt modpack "kubejs");
              symlinks = collectFilesAt modpack "mods";
            };
        };
      };
  };
}
