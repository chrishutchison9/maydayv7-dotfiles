## Minecraft Server Configuration ##
# ? # Run 'systemctl start minecraft-server-NAME' to start the server
# ? # Run 'echo COMMAND > /run/minecraft/NAME.stdin' to run commands
{inputs, ...}: {
  flake.modules.nixos.mc-server = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit
      (builtins)
      attrValues
      listToAttrs
      toString
      ;
    inherit
      (lib)
      concatMap
      mkIf
      mkMerge
      mkOption
      types
      ;
    inherit (pkgs) fetchurl fetchzip linkFarmFromDrvs;

    cfg = config.games.mc-servers;
    dataDir = "/srv/minecraft";
  in {
    imports = [inputs.minecraft.nixosModules.minecraft-servers];

    options.games.mc-servers = mkOption {
      description = "List of Minecraft Servers";
      default = [];
      type = types.listOf (
        types.submodule (
          {config, ...}: {
            options = {
              name = mkOption {
                description = "Unique server name";
                type = types.str;
                default = config.type;
              };

              type = mkOption {
                description = "Server Type";
                type = types.enum [
                  "fabric"
                  "skyblock"
                ];
                default = "fabric";
              };

              memory = mkOption {
                description = "Memory (GB) allocated to server";
                type = types.int;
                default = 12;
              };

              config = mkOption {
                description = "Server Properties";
                type = types.attrs;
                default = {};
              };

              port = mkOption {
                description = "Main server TCP port";
                type = types.int;
                default = 25565;
              };

              vc-port = mkOption {
                description = "Port for Simple Voice Chat";
                type = with types; nullOr int;
                default = null;
              };
            };
          }
        )
      );
    };

    config = mkIf (cfg != []) {
      system.fs.persist.directories = [dataDir];
      networking.firewall = {
        allowedTCPPorts = map (srv: srv.port) cfg;
        allowedUDPPorts = concatMap (srv:
          if (srv.vc-port != null)
          then [srv.vc-port]
          else [])
        cfg;
      };

      services.minecraft-servers = {
        enable = true;
        inherit dataDir;
        eula = true;
        openFirewall = true;
        managementSystem = {
          tmux.enable = false;
          systemd-socket.enable = true;
        };

        servers = listToAttrs (
          map (srv: {
            inherit (srv) name;
            value = mkMerge [
              {
                enable = true;
                autoStart = false;
                serverProperties =
                  srv.config
                  // {
                    server-port = srv.port;
                  };
                jvmOpts = let
                  mem = toString srv.memory;
                in "-Xms${mem}G -Xmx${mem}G --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15";
              }

              ## Fabric Server
              (mkIf (srv.type == "fabric") {
                package = pkgs.fabricServers.fabric-26_1_2;
                symlinks.mods = linkFarmFromDrvs "mods" (
                  attrValues (
                    {
                      # Server
                      FabricAPI = fetchurl {
                        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/NqRnXk9x/fabric-api-0.152.1%2B26.1.2.jar";
                        sha256 = "sha256-slrZJsj9EH0hs6l1Gpjat4dzZSOzmke8LMsEiWJoDXY=";
                      };
                      Lithium = fetchurl {
                        url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/fQBdPR1m/lithium-fabric-0.24.6%2Bmc26.1.2.jar";
                        sha256 = "sha256-UJ5/dwx9SL036VkpFzKdsnaORpXHKkPiLBnvZND5g58=";
                      };
                      Krypton = fetchurl {
                        url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/kYAGItyj/krypton-0.3.0.jar";
                        sha256 = "sha256-dFsRFgQ0dC1EQFRqp+RF0U1ZuhJG5br5kdKTGQuplGM=";
                      };
                      FerriteCore = fetchurl {
                        url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
                        sha256 = "sha256-ITlmxy7ZZ6zHOSvrKKhm+6MB/1a5l2wueAHC233mvyI=";
                      };
                      ScalableLux = fetchurl {
                        url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/gYbHVCz8/ScalableLux-0.2.0%2Bfabric.2b63825-all.jar";
                        sha256 = "sha256-bamBsryRWGU1zjuw+kGXWonMRgO5w6EG0kMaIUF7HfA=";
                      };
                      C2ME = fetchurl {
                        url = "https://cdn.modrinth.com/data/VSNURh3q/versions/v1RNsfu7/c2me-fabric-mc26.1.2-0.4.0-alpha.0.17.jar";
                        sha256 = "sha256-W6hKW/dASyp+A9yT85luhMTg9fF59GTeYoVdRLM6Dx8=";
                      };

                      PlayerRoles = fetchurl {
                        url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/sUiL9n9i/player-roles-1.9.0.jar";
                        sha256 = "sha256-0q6WzsxFdOqrslFmH8C5Si9fADgOShnBhWa4SMcBY/8=";
                      };
                      SkinRestorer = fetchurl {
                        url = "https://cdn.modrinth.com/data/ghrZDhGW/versions/rgcYRGDt/skinrestorer-2.8.1%2B26.1-fabric.jar";
                        sha256 = "sha256-MazpunDTQeMBLN3Da1t5akwBBXH+ia733loqgA4Ft38=";
                      };
                      Silk = fetchurl {
                        url = "https://cdn.modrinth.com/data/aTaCgKLW/versions/dm3Sfg3x/silk-all-1.11.8.jar";
                        sha256 = "sha256-4+u68yBi4nom7b96+PCuJvwpAnQHgtgByjTxYaF5gpM=";
                      };
                      FabricKotlin = fetchurl {
                        url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/Pd0xrHCw/fabric-language-kotlin-1.13.12%2Bkotlin.2.4.0.jar";
                        sha256 = "sha256-NsXdi3KONHDSiCrmMRm5OiBQD8Dqb1yUXBK/ZbWrGDI=";
                      };
                      Veinminer = fetchurl {
                        url = "https://cdn.modrinth.com/data/OhduvhIc/versions/h4Z7xAL0/veinminer-fabric-2.10.3.jar";
                        sha256 = "sha256-/Q4M4yr/kjAMtuSyBeVbgSBMmNoCWrB4tStHSUdUSVk=";
                      };
                      VeinminerEnchant = fetchurl {
                        url = "https://cdn.modrinth.com/data/4sP0LXxp/versions/6zzsM770/veinminer-enchant-2.10.3.jar";
                        sha256 = "sha256-/li1ve6r0w9Mha+9tPO0Vf5mWafQghUpFzZDSEVcivs=";
                      };

                      # Client and Server
                      Jade = fetchurl {
                        url = "https://cdn.modrinth.com/data/nvQzSEkH/versions/zu6GcgEW/Jade-mc26.1-Fabric-26.1.6.jar";
                        sha256 = "sha256-X+1RyaOSVWNyLWRGTKSJErPRYci1XFJVdcbt/rsphS8=";
                      };
                    }
                    // (
                      if (srv.vc-port != null)
                      then {
                        SimpleVC = fetchurl {
                          url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/xmAicr0J/voicechat-fabric-2.6.19%2B26.1.2.jar";
                          sha256 = "sha256-JsPgZqSfRb70Z00m0FN2/noc8Tm4++ncOLt0r0Z0rdQ=";
                        };
                      }
                      else {}
                    )
                  )
                );
              })

              ## Modded Skyblock Server
              (mkIf (srv.type == "skyblock") (
                let
                  inherit (inputs.minecraft.lib) collectFilesAt;

                  # Ozone Skyblock Reborn 2
                  modpack = fetchzip {
                    url = "https://mediafilez.forgecdn.net/files/8061/293/OSR%201.5.4%20-%20Server.zip";
                    sha256 = "sha256-L9bh+MbKgKeD+RezVkmUWSK7kFiUSZrDyPLp7MrPXAY=";
                  };
                in {
                  package = pkgs.neoforgeServers.neoforge-1_21_1;
                  files = (collectFilesAt modpack "config") // (collectFilesAt modpack "kubejs");
                  symlinks = collectFilesAt modpack "mods";
                }
              ))
            ];
          })
          cfg
        );
      };
    };
  };
}
