{
  config,
  lib,
  ...
}: {
  ## Shell Prompt Configuration ##
  options.shell.prompt = lib.mkEnableOption "Enable Fancy Shell Prompt";

  config = lib.mkIf config.shell.prompt {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        continuation_prompt = "⮞⮞ ";
        format = "[╭](fg:base04)$os$directory$git_branch$git_status$fill$c$python$java$nodejs$dotnet$status$cmd_duration$shell$time$username$hostname$line_break$character";

        os = {
          disabled = false;
          format = "(fg:base04)[](fg:white)[$symbol](fg:base01 bg:white)[](fg:white)";
          symbols = {
            Android = "";
            Arch = "";
            Fedora = "";
            Linux = "";
            Macos = "";
            NixOS = "";
            Ubuntu = "";
            Windows = "";
            Unknown = "";
          };
        };

        directory = {
          disabled = false;
          format = "[─](fg:base04)[](fg:blue)[](fg:base01 bg:blue)[](fg:blue bg:base04)[ $read_only$truncation_symbol$path](fg:white bg:base04)[](fg:base04)";
          home_symbol = "~";
          truncation_symbol = "…/";
          truncation_length = 4;
          truncate_to_repo = false;
          read_only = "";
        };

        git_branch = {
          disabled = false;
          format = "[─](fg:base04)[](fg:green)[$symbol](fg:base01 bg:green)[](fg:green bg:base04)[ $branch](fg:white bg:base04)";
          symbol = "";
        };

        git_status = {
          disabled = false;
          format = "[$ahead_behind$all_status](fg:green bg:base04)[](fg:base04)";
          ahead = " ⇡$count";
          behind = " ⇣$count";
          diverged = " ⇡$ahead_count ⇣$behind_count";
          conflicted = " =$count";
          deleted = " ×$count";
          modified = " !$count";
          renamed = " »$count";
          staged = " +$count";
          stashed = " *$count";
          untracked = " ?$count";
          up_to_date = "";
        };

        c = {
          format = "[─](fg:base04)[](fg:blue)[$symbol](fg:base01 bg:blue)[](fg:blue bg:base04)[ $version](fg:white bg:base04)[](fg:base04)";
          symbol = " C";
        };

        python = {
          format = "[─](fg:base04)[](fg:green)[$symbol](fg:base01 bg:green)[](fg:green bg:base04)[ $version](fg:white bg:base04)[](fg:base04)";
          symbol = " Python";
        };

        java = {
          format = "[─](fg:base04)[](fg:red)[$symbol](fg:base01 bg:red)[](fg:red bg:base04)[ $version](fg:white bg:base04)[](fg:base04)";
          symbol = " Java";
        };

        nodejs = {
          format = "[─](fg:base04)[](fg:green)[$symbol](fg:base01 bg:green)[](fg:green bg:base04)[ $version](fg:white bg:base04)[](fg:base04)";
          symbol = "󰎙 Node.js";
        };

        dotnet = {
          format = "[─](fg:base04)[](fg:purple)[$symbol](fg:base01 bg:purple)[](fg:purple bg:base04)[ $tfm](fg:white bg:base04)[](fg:base04)";
          symbol = " .NET";
        };

        fill = {
          symbol = "─";
          style = "fg:base04";
        };

        status = {
          disabled = false;
          format = "[─](fg:base04)[](fg:red)[](fg:base01 bg:red)[](fg:red bg:base04)[ $status](fg:white bg:base04)[](fg:base04)";
        };

        cmd_duration = {
          min_time = 500;
          format = "[─](fg:base04)[](fg:orange)[󰦖](fg:base01 bg:orange)[](fg:orange bg:base04)[ $duration](fg:white bg:base04)[](fg:base04)";
        };

        shell = {
          disabled = false;
          format = "[─](fg:base04)[](fg:purple)[](fg:base01 bg:purple)[](fg:purple bg:base04)[ $indicator](fg:white bg:base04)[](fg:base04)";
          bash_indicator = "bash";
          fish_indicator = "fish";
          zsh_indicator = "zsh";
          unknown_indicator = "shell";
        };

        time = {
          disabled = false;
          format = "[─](fg:base04)[](fg:yellow)[](fg:base01 bg:yellow)[](fg:yellow bg:base04)[ $time](fg:white bg:base04)[](fg:base04)";
          time_format = "%H:%M";
        };

        username = {
          format = "[─](fg:base04)[](fg:bright-blue)[](fg:base01 bg:bright-blue)[](fg:bright-blue bg:base04)[ $user]($style bg:base04)[](fg:base04)";
          show_always = true;
          style_user = "fg:white";
          style_root = "bold fg:red";
        };

        hostname = {
          disabled = false;
          format = "[─](fg:base04)[](fg:cyan)[](fg:base01 bg:cyan)[](fg:cyan bg:base04)[ $hostname](fg:white bg:base04)[](fg:base04)";
          ssh_only = false;
        };

        character = {
          format = "[╰─$symbol](fg:base04) ";
          success_symbol = "[⮞](fg:bold white)";
          error_symbol = "[⮞](fg:bold red)";
        };

        palette = "base16";
        palettes.base16 = with config.lib.stylix.colors.withHashtag; {
          black = base00;
          bright-black = base03;
          white = base05;
          bright-white = base07;
          bright-yellow = yellow;
          purple = magenta;
          bright-purple = bright-magenta;
          inherit
            blue
            brown
            cyan
            green
            magenta
            orange
            red
            yellow
            bright-blue
            bright-cyan
            bright-green
            bright-magenta
            bright-orange
            bright-red
            base00
            base01
            base02
            base03
            base04
            base05
            base06
            base07
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
            ;
        };
      };
    };
  };
}
