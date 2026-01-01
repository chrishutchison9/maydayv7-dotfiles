{
  site ? null,
  pkgs,
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "website";
  version = "stable";
  src = ./.;
  buildInputs = [ pkgs.zola ];
  installPhase = "cp -r public $out";
  buildPhase = "zola build ${if (site != null) then "--base-url " + site else ""}";
}
