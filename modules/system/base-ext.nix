## Extended Base Configuration ##
_: {
  flake.modules = {
    nixos.base-ext = _: {
      config = {
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
      };
    };
  };
}
