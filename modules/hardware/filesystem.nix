{
  config,
  options,
  lib,
  inputs,
  pkgs,
  files,
  ...
}:
let
  inherit (builtins) listToAttrs mapAttrs;
  inherit (lib)
    filterAttrs
    hasPrefix
    mkAfter
    mkAliasOptionModule
    mkForce
    mkIf
    mkMerge
    mkOption
    nameValuePair
    optional
    types
    ;

  inherit (config.hardware.fs) scheme;
in
{
  ## File System Configuration ##
  imports = [
    inputs.impermanence.nixosModule
  ]
  ++ [
    (mkAliasOptionModule [ "environment" "persist" ] [ "environment" "persistence" files.path.persist ])
    (mkAliasOptionModule [ "hardware" "fs" "persist" ] [ "environment" "persistence" files.path.data ])
  ];

  options = with types; {
    hardware.fs.scheme = mkOption {
      description = "Disk Filesystem Scheme";
      type = nullOr (enum [
        "simple"
        "advanced"
      ]);
      default = null;
    };

    user.persist = {
      files = mkOption {
        description = "Additional User Files to Preserve";
        type = listOf str;
        default = [ ];
        example = [ ".bash_history" ];
      };

      directories = mkOption {
        description = "Additional User Directories to Preserve";
        type = listOf (either str attrs);
        default = [ ];
        example = [ "Downloads" ];
      };
    };
  };

  config = mkMerge [
    {
      warnings = optional (scheme == null) (options.hardware.fs.scheme.description + " is unset");

      ## Common Partitions
      boot.supportedFilesystems = {
        ntfs = true;
        vfat = true;
        zfs = true;
      };
    }

    (mkIf (scheme != null) {
      programs.fuse.userAllowOther = true;

      # EFI System Partition
      fileSystems."/boot" = {
        device = "/dev/disk/by-partlabel/ESP";
        fsType = "vfat";
      };

      # SWAP Partition
      swapDevices = [ { device = "/dev/disk/by-partlabel/swap"; } ];
      boot.kernel.sysctl."vm.swappiness" = 1;

      system.activationScripts.dotfiles =
        with files.path;
        let
          path = if scheme == "advanced" then "${persist}/" else "";
          dir = "${path}${system}";
        in
        ''
          chown root:keys ${dir}
          chmod 774 -R ${dir}
        '';
    })

    ## Simple File System Configuration using EXT4 ##
    (mkIf (scheme == "simple") {
      fileSystems = {
        # ROOT Partition
        "/" = {
          device = "/dev/disk/by-partlabel/System";
          fsType = "ext4";
        };
      };
    })

    ## Advanced File System Configuration using ZFS ##
    (mkIf (scheme == "advanced") (
      let
        rollback = ''
          zfs rollback -r fspool/system/root@blank && echo "Rollback Complete!"
        '';
      in
      {
        fileSystems = {
          # ROOT Partition
          "/" = {
            device = "fspool/system/root";
            fsType = "zfs";
          };

          # NIX Partition
          "/nix" = {
            device = "fspool/system/nix";
            fsType = "zfs";
          };

          # PERSISTENT Partition
          "${files.path.data}" = {
            device = "fspool/data";
            fsType = "zfs";
            neededForBoot = true;
          };
        }
        // filterAttrs (name: _: hasPrefix "/etc" name) (
          listToAttrs (
            map (
              item: nameValuePair item.directory { neededForBoot = true; }
            ) config.environment.persist.directories
          )
        );

        # Boot Settings
        boot = {
          resumeDevice = "/dev/disk/by-partlabel/swap";
          kernelParams = [ "elevator=none" ];
          zfs = {
            allowHibernation = true;
            forceImportRoot = false;
            forceImportAll = false;
            devNodes = "/dev/disk/by-partlabel/System";
          };

          initrd.systemd = {
            enable = true;
            services.rollback = {
              description = "Wipe ZFS partition for Opt-In State Configuration";
              wantedBy = [ "initrd.target" ];
              after = [ "zfs-import-fspool.service" ];
              before = [ "sysroot.mount" ];
              path = [ pkgs.zfs ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = rollback;
            };
          };
        };

        # Debug
        specialisation.recovery.configuration = {
          boot.initrd = {
            systemd.enable = mkForce false;
            postResumeCommands = mkAfter rollback;
          };
        };

        # Persisted Files
        environment.persistence = {
          "${files.path.persist}" = {
            files = [ "/etc/machine-id" ];
            directories = [
              files.path.system
              "/var/log"
              "/var/lib/AccountsService"
              "/var/lib/nixos"
              "/var/lib/systemd/coredump"
            ];
          };

          "${files.path.data}" = {
            hideMounts = true;
            users = mapAttrs (_: _: {
              inherit (config.user.persist) files;
              directories = [
                "Desktop"
                "Documents"
                "Downloads"
                "Music"
                "Pictures"
                "Projects"
                "Public"
                "Videos"
                {
                  directory = ".local/share/keyrings";
                  mode = "0700";
                }
              ]
              ++ config.user.persist.directories;
            }) config.user.settings;
          };
        };

        # Maintainence
        services.zfs = {
          trim.enable = true;
          autoScrub.enable = true;
          autoSnapshot = {
            enable = true;
            hourly = 12;
            daily = 7;
            weekly = 3;
            monthly = 1;
          };
        };

        systemd.user.services.persist-trash = {
          description = "Persist Trash Folder";
          wantedBy = [ "default.target" ];
          path = [ pkgs.coreutils ];
          serviceConfig =
            let
              run =
                script:
                "${
                  pkgs.writeShellApplication {
                    name = "script";
                    runtimeInputs = [ pkgs.coreutils ];
                    text = ''
                      LOCAL="$HOME/.local/share/Trash"
                      PERSIST="${files.path.data}/home/$USER/Trash"
                      mkdir -p "$LOCAL"
                      ${script}
                    '';
                  }
                }/bin/script";
            in
            {
              Type = "oneshot";
              RemainAfterExit = true;
              StandardOutput = "journal";
              ExecStart = run ''
                if [ -d "$PERSIST" ]
                then
                  cp -r "$PERSIST"/. "$LOCAL"
                  rm -rf "$PERSIST"
                fi
              '';
              ExecStop = run ''
                mkdir -p "$PERSIST"
                cp -r "$LOCAL"/. "$PERSIST"
              '';
            };
        };
      }
    ))
  ];
}
