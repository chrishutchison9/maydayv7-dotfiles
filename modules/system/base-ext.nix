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
          font-name=${config.stylix.fonts.monospace.name}
          font-size=14
        '';
      };
    };
  };
}
