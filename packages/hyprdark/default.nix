{
  lib,
  pkgs,
  ...
}:
with pkgs; let
  metadata = import ./metadata.nix;
in
  gcc13Stdenv.mkDerivation rec {
    pname = "Hypr-DarkWindow";
    version = metadata.rev;

    src = fetchFromGitHub {
      owner = "micha4w";
      repo = pname;
      inherit (metadata) rev sha256;
    };

    nativeBuildInputs = [pkg-config];
    buildInputs = [hyprland.dev] ++ hyprland.buildInputs;
    installPhase = ''
      mkdir -p $out/lib
      install ./out/hypr-darkwindow.so $out/lib/libHypr-DarkWindow.so
    '';

    meta = with lib; {
      homepage = metadata.repo;
      description = "Hyprland Plugin to invert the colors of specific windows";
      license = licenses.mit;
      platforms = platforms.linux;
      maintainers = ["maydayv7"];
    };
  }
