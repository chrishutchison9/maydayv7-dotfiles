{
  lib,
  pkgs,
  ...
}:
with pkgs; let
  metadata = import ./metadata.nix;
in
  rustPlatform.buildRustPackage rec {
    pname = "hyprswitch";
    version = metadata.rev;

    src = fetchFromGitHub {
      owner = "H3rmt";
      repo = pname;
      inherit (metadata) rev sha256;
    };

    useFetchCargoVendor = true;
    inherit (metadata) cargoHash;
    buildInputs = [gtk4-layer-shell];
    nativeBuildInputs = [
      wrapGAppsHook4
      pkg-config
    ];

    meta = with lib; {
      mainProgram = "hyprswitch";
      description = "CLI/GUI that allows switching between windows in Hyprland";
      homepage = metadata.repo;
      license = licenses.mit;
      platforms = platforms.linux;
      maintainers = ["maydayv7"];
    };
  }
