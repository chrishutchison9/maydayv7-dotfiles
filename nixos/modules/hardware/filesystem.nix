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
  inherit (builtins) listToAttrs map;
  inherit (lib)
    filterAttrs
    getExe
    hasPrefix
    mkAliasOptionModule
    mkDefault
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

  options.hardware.fs.scheme = mkOption {
    description = "Disk Filesystem Scheme";
    type =
      with types;
      nullOr (enum [
        "simple"
        "advanced"
      ]);
    default = null;
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
    {
      environment.persist.enable = mkDefault false;
      hardware.fs.persist.enable = mkDefault false;
      user.homeConfig.imports = [
        (mkAliasOptionModule [ "home" "persist" ] [ "home" "persistence" files.path.data ])
        (_: { home.persist.enable = mkDefault false; })
      ];
    }
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
        # Early Boot Requirements
        // filterAttrs (name: _: hasPrefix "/etc" name) (
          listToAttrs (
            map (
              item:
              nameValuePair item.directory {
                device = "${files.path.persist}${item.directory}";
                fsType = "none";
                options = [ "bind" ];
                neededForBoot = true;
              }
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

        # Persisted Files
        hardware.fs.persist.enable = true;
        environment.persistence."${files.path.persist}" = {
          enable = true;
          files = [ "/etc/machine-id" ];
          directories = [
            files.path.system
            "/var/log"
            "/var/lib/AccountsService"
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"
          ];
        };

        user.homeConfig = {
          home.persistence."${files.path.data}" = {
            enable = true;
            allowTrash = true;
            hideMounts = true;
            directories = [
              "Desktop"
              "Documents"
              "Downloads"
              "Music"
              "Pictures"
              "Public"
              "Videos"
              {
                directory = ".local/share/keyrings";
                mode = "0700";
              }
            ];
          };

          systemd.user.services.persist-trash = {
            Unit.Description = "Persist Trash Folder";
            Install.WantedBy = [ "default.target" ];
            Service =
              let
                run =
                  script:
                  getExe (
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
                  );
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
        };
      }
    ))
  ];
}
