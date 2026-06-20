## Extended Base Configuration ##
_: {
  flake.modules = {
    nixos.base-ext = {config, ...}: {
      # AppImage Support
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      # Documentation
      documentation = {
        dev.enable = true;
        man.enable = true;
      };

      # TTY
      services.kmscon = {
        enable = true;
        hwRender = false;
        extraConfig = ''
          font-name=${builtins.head config.fonts.fontconfig.defaultFonts.monospace}
          font-size=14
        '';
      };
    };
  };
}
