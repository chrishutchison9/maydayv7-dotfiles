{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) any attrValues elem;
  enable = any (value: elem "bash" value.shells) (attrValues config.user.settings);
in {
  ## Bourne Shell Configuration ##
  config = lib.mkIf enable {
    # Shell Environment
    environment.shells = [pkgs.bashInteractive];
    user.persist = {
      files = [".bash_history"];
      directories = [".local/share/bash"];
    };

    programs.bash = {
      vteIntegration = true;
      promptInit = ''
        # Options
        shopt -s autocd
        shopt -s cdspell
        shopt -s checkjobs
        shopt -s checkwinsize
        shopt -s cmdhist
        shopt -s extglob
        shopt -s globstar
        shopt -s histappend
        shopt -s no_empty_cmd_completion

        # Command History
        HISTCONTROL=erasedups:ignoredups:ignorespace
        HISTFILESIZE=100000
        HISTIGNORE=rm:killall
        HISTSIZE=100000
      '';
    };
  };
}
