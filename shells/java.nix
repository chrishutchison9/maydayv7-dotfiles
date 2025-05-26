pkgs: {
  name = "Java";
  shellHook = ''echo "## Java Development Shell ##"'';
  packages = [ pkgs.jdk ];
  JAVA_HOME = pkgs.jdk;
}
