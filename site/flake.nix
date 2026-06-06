{
  description = "My Personal Website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    systems = {
      url = "github:maydayv7/dotfiles?ref=systems";
      flake = false;
    };

    framework = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    formatter = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stagit = {
      url = "github:maydayv7/stagit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.framework.lib.mkFlake { inherit inputs; } {
      inherit (self) systems;
      flake.systems = import inputs.systems;
      imports = [ inputs.formatter.flakeModule ];
      perSystem =
        {
          config,
          lib,
          system,
          ...
        }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                stagit-fork = inputs.stagit.packages.${system}.default;
              })
            ];
          };
        in
        {
          # Website
          packages = rec {
            default = website;
            website = pkgs.callPackage ./. { inherit lib pkgs; };
          };

          # 'git' Frontend
          apps = rec {
            default = build-stagit;
            build-stagit = {
              type = "app";
              program = lib.getExe (pkgs.callPackage ./git { inherit lib pkgs; });
            };
          };

          # Development Shell
          devShells = rec {
            default = website;
            website = import ./shell.nix { inherit pkgs; };
          };

          # Formatting
          treefmt.config = {
            projectRootFile = "flake.nix";
            settings.global.excludes = [
              "_*"
              "result/**"
              "flake.lock"
            ];

            programs = {
              nixfmt.enable = true;
              prettier = {
                enable = true;
                settings.bracketSameLine = true;
                excludes = [
                  "templates/macros/edit.html"
                  "templates/macros/head.html"
                  "templates/macros/javascript.html"
                  "templates/macros/menu.html"
                  "templates/macros/posts.html"
                  "templates/tags/list.html"
                ];
              };
            };
          };
        };
    };
}
