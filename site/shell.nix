{pkgs ? import <nixpkgs> {}, ...}:
pkgs.mkShell {
  name = "Website";
  packages = with pkgs; [
    git
    zola
    wrangler
  ];
  shellHook = ''echo "## Website Builder Shell ##"'';
}
