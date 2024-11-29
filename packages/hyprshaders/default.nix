{
  lib,
  pkgs,
  ...
}:
with pkgs;
  stdenv.mkDerivation {
    pname = "hyprshaders";
    version = "v2";

    srcs = [
      ./dim.frag
      (fetchFromGitHub {
        owner = "hyprland-community";
        repo = "awesome-hyprland";
        rev = "9978013d307fd205c6d61296bda3dfdb7e8282f1";
        sha256 = "sha256-giMv5+1WfEFc5jfwPSNxu6V+puWOyTfVpNVrd2aQvKE=";
      })
    ];

    dontBuild = true;
    unpackPhase = ''
      for src in $srcs
      do
        cp -r $src $(stripHash $src)
      done
    '';

    installPhase = ''
      mkdir -p $out/share/hypr/shaders/
      find . -name '*.frag' ! -name 'blue*' ! -name 'vibrance*' \
        -exec cp {} $out/share/hypr/shaders/ \;
    '';

    meta = with lib; {
      description = "Shaders for Hyprland";
      homepage = "https://github.com/hyprland-community/awesome-hyprland";
      license = licenses.cc0;
      maintainers = ["maydayv7"];
    };
  }
