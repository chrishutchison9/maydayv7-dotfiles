{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.nix.tools = lib.mkEnableOption "Enable Additional Nix Tools";

  ## Nix Tools ##
  config = lib.mkIf config.nix.tools {
    user.homeConfig.home.persist.directories = [ ".cache/manix" ];
    nix.settings.system-features = [
      "kvm"
      "big-parallel"
      "recursive-nix"
    ];

    environment.systemPackages = with pkgs; [
      cachix
      dix
      manix
      nixfmt
      nix-output-monitor
      nodePackages.prettier
      shellcheck
      statix
    ];
  };
}
