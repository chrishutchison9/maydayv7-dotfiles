pkgs: {
  name = "JS";
  shellHook = ''echo "## JavaScript Development Shell ##"'';
  packages = with pkgs; [
    nodejs
    eslint

    nodemon
    postman
  ];
}
