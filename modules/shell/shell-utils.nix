## Shell Utilities ##
{config, ...}: let
  inherit (config.flake) files;
in {
  flake.modules = {
    nixos.shell-utils = {pkgs, ...}: {
      config = {
        environment = {
          # Utilities
          systemPackages = with pkgs; [
            bat
            btop
            eza
            fastfetch
            fd
            hstr
            lolcat
            tree
            yazi
            zellij
          ];

          # Fetch
          etc."fastfetch/config.jsonc".text = files.fetch;

          # Command Aliases
          shellAliases = {
            hi = "echo 'Hi there. How are you?'";
            bye = "exit";
            dotfiles = "cd ${files.path.system}";
            c = "bat";
            l = "eza -b -h -l -F --octal-permissions --time-style iso";
            grep = "grep --color";
            colors = "${files.scripts.colors}";
            sike = "fastfetch";
          };
        };

        ## Program Configuration
        services.lorri.enable = true;
        programs = {
          # Command Correction Helper
          pay-respects = {
            enable = true;
            alias = "fix";
          };

          # DirENV Support
          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
        };
      };
    };

    homeManager.shell-utils = _: {
      home.persist = {
        files = [".hstr_favorites"];
        directories = [".local/share/direnv"];
      };

      programs = {
        btop.enable = true; # Resource Monitor
        hstr.enable = true; # Command History Manager
        yazi.enable = true; # File Manager
        zellij.enable = true; # Terminal Multiplexer

        # Pager
        bat = {
          enable = true;
          config = {
            style = "full";
            italic-text = "always";
          };
        };

        # File Lister
        eza = {
          enable = true;
          colors = "auto";
          icons = "auto";
          git = true;
          extraOptions = ["--group-directories-first"];
        };
      };
    };
  };
}
