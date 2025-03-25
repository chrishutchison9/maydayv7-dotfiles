{
  config,
  lib,
  pkgs,
  theme,
  ...
}: let
  inherit (builtins) concatStringsSep elem map;
  exists = app: elem app config.apps.list;
in {
  ## 3rd Party Apps Configuration
  user.homeConfig = {
    # Code Editor
    programs.vscode.profiles.default = lib.mkIf (exists "vscode") {
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

      # KDE Apps
      ".config/kdeglobals".text = with config.lib.stylix.colors;
        ''
          [Colors:Selection]
          BackgroundNormal=${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}
          BackgroundAlternate=${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}
          ForegroundNormal=${base00-rgb-r},${base00-rgb-g},${base00-rgb-b}
          ForegroundActive=${base00-rgb-r},${base00-rgb-g},${base00-rgb-b}
          ForegroundInactive=${base00-rgb-r},${base00-rgb-g},${base00-rgb-b}
          ForegroundLink=${base00-rgb-r},${base00-rgb-g},${base00-rgb-b}
          ForegroundVisited=${base00-rgb-r},${base00-rgb-g},${base00-rgb-b}
        ''
        + (concatStringsSep "\n" (map (
            name: ''
              [Colors:${name}]
              BackgroundNormal=${base00-rgb-r},${base00-rgb-g},${base00-rgb-b}
              BackgroundAlternate=${base01-rgb-r},${base01-rgb-g},${base01-rgb-b}
              DecorationFocus=${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}
              DecorationHover=${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}
              ForegroundNormal=${base05-rgb-r},${base05-rgb-g},${base05-rgb-b}
              ForegroundActive=${base05-rgb-r},${base05-rgb-g},${base05-rgb-b}
              ForegroundInactive =${base05-rgb-r},${base05-rgb-g},${base05-rgb-b}
              ForegroundLink=${base05-rgb-r},${base05-rgb-g},${base05-rgb-b}
              ForegroundVisited=${base05-rgb-r},${base05-rgb-g},${base05-rgb-b}
              ForegroundNegative=${base08-rgb-r},${base08-rgb-g},${base08-rgb-b}
              ForegroundNeutral=${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}
              ForegroundPositive=${base0B-rgb-r},${base0B-rgb-g},${base0B-rgb-b}
            ''
          ) [
            "View"
            "Window"
            "Button"
            "Tooltip"
            "Complementary"
          ]));
    };
  };
}
