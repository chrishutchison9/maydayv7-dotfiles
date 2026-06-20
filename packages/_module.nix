## Package Configuration ##
{
  config,
  inputs,
  lib,
  ...
}: let
  map = import ../lib/map.nix lib;
  inherit (builtins) any attrValues isPath;
in {
  perSystem = {
    self',
    system,
    lib,
    inputs',
    pkgs,
    ...
  }:
    rec {
      _module.args.pkgs = legacyPackages;
      legacyPackages = with inputs; let
        nixpkgsConfig = import ./_config.nix;
      in
        import (config.flake.patchedPkgs system) {
          inherit system;
          config = nixpkgsConfig;

          overlays =
            (attrValues config.flake.overlays or {})
            ++ [
              (final: _: {
                custom = config.flake.packages."${system}" or {};
                stagit-fork = stagit.packages."${system}".default;
                unstable = import unstable {
                  inherit system;
                  config = nixpkgsConfig;
                };

                wine = windows.packages."${system}";
                winelib = windows.lib."${system}";
                spicetify = spicetify.legacyPackages."${system}";
                hyprworld = let
                  hyprlandPkg = hyprland.packages."${system}".hyprland;
                  Hyprspace = final.gcc14Stdenv.mkDerivation {
                    pname = "Hyprspace";
                    src = hyprspace;
                    inherit (hyprlandPkg) version nativeBuildInputs;
                    buildInputs = [hyprlandPkg] ++ hyprlandPkg.buildInputs;
                    dontUseCmakeConfigure = true;
                    installFlags = ["PREFIX=$(out)"];
                    postInstall = "mv $out/lib/Hyprspace.so $out/lib/libHyprspace.so";
                  };
                in
                  hyprland.packages."${system}"
                  // hyprsplit.packages."${system}"
                  // hyprcursors.packages."${system}"
                  // {inherit Hyprspace;};
              })
              minecraft.overlay
              vscode.overlays.default
            ];
        };
    }
    // (
      let
        call = rec {
          __functor = _: name: pkg name {};
          pkg = name: args: pkgs.callPackage name ({inherit lib pkgs;} // {inherit (config) util;} // args);
          script = name:
            pkg name {
              inherit inputs;
              inherit (config.flake) files;
            };
        };
      in {
        packages =
          map.modules ../packages call // map.modules ../scripts call.script // inputs'.proprietary.packages;
        apps =
          map.modules ../scripts (
            name: let
              drv = call.script name;
            in {
              type = "app";
              program = lib.getExe drv;
              meta = drv.meta or {};
            }
          )
          // {
            default = self'.apps.nixos;
          };
      }
    );

  flake = {
    patchedPkgs = system: let
      src = inputs.nixpkgs;
      patches = map.patches ./patches;
      pkgs' = import src {inherit system;};
    in
      if !(any isPath patches)
      then src
      else
        pkgs'.applyPatches {
          inherit src patches;
          name = "nixpkgs-patched-${src.shortRev}";
        };

    overlays = map.modules ./overlays import;
  };
}
