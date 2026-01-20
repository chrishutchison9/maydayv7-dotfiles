{
  self,
  util,
  inputs,
  ...
}:
let
  inherit (util) map;
  inherit (builtins) any attrValues isPath;
in
{
  ## Packages Configuration ##
  perSystem =
    {
      self',
      system,
      lib,
      inputs',
      pkgs,
      ...
    }:
    rec {
      # Package Channel
      _module.args.pkgs = legacyPackages;
      legacyPackages =
        with inputs;
        let
          # Package Configuration
          config = import ../modules/nix/config.nix;
        in
        import (self.patchedPkgs system) {
          inherit system config;

          # Package Overrides
          overlays = (attrValues self.overlays or { }) ++ [
            (_: _: {
              custom = self.packages."${system}";
              stagit-fork = stagit.packages."${system}".default;
              unstable = import unstable { inherit system config; };

              gaming = gaming.packages."${system}";
              wine = windows.packages."${system}";
              winelib = windows.lib."${system}";
              spicetify = spotify.legacyPackages."${system}";
              hyprworld =
                hyprland.packages."${system}" // hyprsplit.packages."${system}" // hyprcursors.packages."${system}";
            })
            minecraft.overlay
            niri.overlays.niri
            vscode.overlays.default
          ];
        };
    }
    // (
      let
        # Package Calling Function
        call = rec {
          __functor = _: name: pkg name { };
          pkg = name: args: pkgs.callPackage name ({ inherit lib util pkgs; } // args);
          script =
            name:
            pkg name {
              inherit inputs;
              inherit (inputs.self) files;
            };
        };
      in
      {
        # Custom Packages
        packages =
          map.modules ./. call // map.modules ../scripts call.script // inputs'.proprietary.packages;
        apps =
          map.modules ../scripts (
            name:
            let
              drv = call.script name;
            in
            {
              type = "app";
              program = lib.getExe drv;
              meta = drv.meta or { };
            }
          )
          // {
            default = self'.apps.nixos;
          };
      }
    );

  flake = {
    # Patched Source
    patchedPkgs =
      system:
      let
        src = inputs.nixpkgs;
        patches = map.patches ./patches;
        pkgs' = import src { inherit system; };
      in
      if !(any isPath patches) then
        src
      else
        pkgs'.applyPatches {
          inherit src patches;
          name = "nixpkgs-patched-${src.shortRev}";
        };

    # Package Overrides
    overlays = map.modules ./overlays import;
  };
}
