{
  lib,
  pkgs,
  ...
}:
with pkgs; let
  metadata = import ./metadata.nix;
in
  gcc13Stdenv.mkDerivation rec {
    pname = "hycov";
    version = metadata.rev;

    src = fetchFromGitHub {
      owner = "bighu630";
      repo = pname;
      inherit (metadata) rev sha256;
    };

    inherit (hyprland) nativeBuildInputs;
    buildInputs = [hyprland.dev] ++ hyprland.buildInputs;

    meta = with lib; {
      homepage = metadata.repo;
      description = "Hyprland Plugin for application overview";
      license = licenses.mit;
      platforms = platforms.linux;
      maintainers = ["maydayv7"];
    };
  }
