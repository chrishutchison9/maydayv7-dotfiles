# Obsidian Package Builders #
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
}: {
  mkTheme = {
    pname,
    meta ? {},
    ...
  } @ metadata:
    stdenvNoCC.mkDerivation {
      inherit pname;
      version = builtins.substring 0 7 metadata.rev;

      src = fetchFromGitHub {
        inherit (metadata) owner repo rev;
        hash = metadata.sha256;
      };

      dontBuild = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp manifest.json theme.css $out/
        runHook postInstall
      '';

      meta = {maintainers = ["maydayv7"];} // meta;
    };

  mkPlugin = {
    pname,
    owner,
    repo,
    version,
    hashes,
    meta ? {},
    ...
  }: let
    base = "https://github.com/${owner}/${repo}/releases/download/${version}";
    main = fetchurl {
      url = "${base}/main.js";
      hash = hashes.main;
    };
    manifest = fetchurl {
      url = "${base}/manifest.json";
      hash = hashes.manifest;
    };
    styles =
      if hashes ? styles
      then
        fetchurl {
          url = "${base}/styles.css";
          hash = hashes.styles;
        }
      else null;
  in
    stdenvNoCC.mkDerivation {
      inherit pname version;

      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp ${main} $out/main.js
        cp ${manifest} $out/manifest.json
        ${lib.optionalString (styles != null) "cp ${styles} $out/styles.css"}
        runHook postInstall
      '';

      meta = {maintainers = ["maydayv7"];} // meta;
    };
}
