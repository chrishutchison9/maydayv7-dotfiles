{
  config,
  lib,
  pkgs,
  theme,
  ...
}: let
  exists = app: builtins.elem app config.apps.list;
in {
  ## 3rd Party Apps Configuration
  user.homeConfig = {
    # Code Editor
    programs.vscode = lib.mkIf (exists "vscode") {
      extensions = with pkgs; [
        vscode-extensions.catppuccin.catppuccin-vsc-icons
        (catppuccin-vsc.override {
          inherit (theme) accent;
          boldKeywords = true;
          italicComments = true;
          italicKeywords = true;
          extraBordersEnabled = false;
          workbenchMode = "default";
          bracketMode = "rainbow";
        })
      ];

      userSettings = with theme; {
        "workbench.colorTheme" = "${name-alt} ${variant-alt}";
        "workbench.iconTheme" = "${name}-${variant}";
        "terminal.external.linuxExec" = config.gui.launcher.terminal;
      };
    };

    home.file = {
      # Discord Chat
      ".config/vesktop/settings/quickCss.css" = with theme;
        lib.mkIf (exists "discord") {text = ''@import url("https://${name}.github.io/discord/dist/${name}-${variant}-${accent}.theme.css");'';};

      # Logseq Notes
      ".logseq/config.edn" = with theme;
        lib.mkIf (exists "notes") {text = ''{:custom-css-url "@import url('https://logseq.${name}.com/ctp-${variant}.css');"}'';};
    };
  };
}
