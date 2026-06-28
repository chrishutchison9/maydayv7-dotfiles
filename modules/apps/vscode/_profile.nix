## Shared Editor Profile
{
  lib,
  pkgs,
  files,
  font,
  isGnome,
  isWM,
}:
with files.vscode; {
  # Keyboard Shortcuts
  inherit keybindings;

  # Settings
  userSettings = lib.mkMerge [
    (settings
      // {
        "workbench.colorTheme" = lib.mkDefault "Dark 2026";
        "editor.fontFamily" = "'${font}', 'monospace', monospace";
      })
    (lib.mkIf isGnome {
      "workbench.productIconTheme" = "adwaita";
      "terminal.external.linuxExec" = "ghostty";
    })
    (lib.mkIf isWM {
      "terminal.external.linuxExec" = "kitty";
    })
    (let
      lemminx = "${pkgs.lemminx}/bin/lemminx";
    in {
      "xml.server.preferBinary" = true;
      "xml.server.binary.path" = lemminx;
      "xml.server.binary.trustedHashes" = [(builtins.hashFile "sha256" lemminx)];
    })
  ];

  ## Editor Extensions
  extensions = with pkgs.vscode-extensions;
    [
      aaron-bond.better-comments # Annotations
      editorconfig.editorconfig # .editorconfig
      esbenp.prettier-vscode # Formatter
      file-icons.file-icons # File Icons
      naumovs.color-highlight # Color Viewer
      johnpapa.vscode-peacock # Workspace Color

      github.vscode-pull-request-github # GitHub
      github.copilot # Copilot AI
      dart-code.flutter # Flutter
      jnoortheen.nix-ide # Nix
      ms-python.python # Python
      ms-vscode.cpptools # C/C++
      redhat.java # Java
      rust-lang.rust-analyzer # Rust
      tomoki1207.pdf # PDF Viewer
      yzhang.markdown-all-in-one # Markdown

      # HTML/CSS/XML
      ecmel.vscode-html-css
      formulahendry.auto-rename-tag
      redhat.vscode-xml

      # JS
      dbaeumer.vscode-eslint
      ritwickdey.liveserver
    ]
    ++ (with pkgs.vscode-marketplace; [
      langningchen.cph-ng # CP
      kisstkondoros.vscode-gutter-preview # Image Preview
    ])
    ++ lib.optionals isGnome [pkgs.vscode-extensions.piousdeer.adwaita-theme];
}
