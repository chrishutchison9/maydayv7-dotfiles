pkgs: {
  name = "Rust";
  shellHook = ''echo "## Rust Development Shell ##"'';
  packages = with pkgs; [
    cargo
    rustup
  ];
  RUST_BACKTRACE = 1;
}
