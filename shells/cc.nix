pkgs: {
  name = "C";
  shellHook = ''echo "## C/C++ Development Shell ##"'';
  LIBCLANG_PATH = "${pkgs.libclang}/lib";
  packages = with pkgs; [
    clang
    cmake
    gcc
    gdb
    libcxx
  ];
}
