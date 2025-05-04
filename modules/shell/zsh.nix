{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) any attrValues elem;
  enable = any (value: elem "zsh" value.shells) (attrValues config.user.settings);
in
{
  ## Z Shell Configuration ##
  config = lib.mkIf enable {
    # Shell Environment
    programs.zsh = {
      enable = true;

      # Features
      autosuggestions.enable = true;
      enableCompletion = false;
      syntaxHighlighting.enable = true;
      vteIntegration = true;
      setOptions = [
        "autocd"
        "EXTENDED_HISTORY"
        "HIST_EXPIRE_DUPS_FIRST"
      ];

      # Keybindings
      promptInit = ''
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
        bindkey '^[[3;5~' kill-word
        bindkey '^[[3~'   delete-char
        bindkey "^[[5~"   beginning-of-history
        bindkey "^[[6~"   end-of-history
        bindkey '^[[A'    up-line-or-search
        bindkey '^[[B'    down-line-or-search
        bindkey '^[[C'    forward-char
        bindkey '^[[D'    backward-char
        bindkey '^[[F'    end-of-linegestures
        bindkey '^[[H'    beginning-of-line
        bindkey '^J'      backward-kill-line
      '';

      # Plugins
      interactiveShellInit = ''
        source ${pkgs.zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh
      '';
    };

    system.userActivationScripts.zshrc = "touch .zshrc";
    user.persist = {
      files = [ ".zsh_history" ];
      directories = [ ".cache/zsh" ];
    };
  };
}
