final: prev: {
  # GitHub Copilot CLI
  github-copilot-cli = prev.github-copilot-cli.overrideAttrs (_: rec {
    version = "1.0.64";
    src = prev.fetchurl {
      url = "https://github.com/github/copilot-cli/releases/download/v${version}/github-copilot-${version}-linux-x64.tgz";
      hash = "sha256-p2I4BHdW9wRLP8ns7wmuWBwUW2RGOuARgDtItMovxGA=";
    };
  });
}
