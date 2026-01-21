{
  config,
  lib,
  pkgs,
  files,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
{
  # Personal Credentials
  credentials = {
    name = "maydayv7";
    fullname = "V7";
    mail = "maydayv7@gmail.com";
    key = "8C240C0C11293EE56260601CCF616EB19C2765E4";
  };

  # Home Configuration
  home = {
    packages = [ pkgs.home-manager ];
    persist.directories = [
      "TBD"
      "Projects"
    ];

    # Directory Symlinks
    file = {
      # Profile Picture
      ".face".source = ./profile.png;

      # Online Accounts
      ".config/goa-1.0/accounts.conf".text = builtins.readFile ./accounts.conf;

      # Dotfiles
      "Projects/dotfiles".source = config.lib.file.mkOutOfStoreSymlink files.path.system;

      # GTK+ Bookmarks
      ".config/gtk-3.0/bookmarks".text = lib.mkBefore ''
        file://${homeDir}/TBD TBD
        file://${homeDir}/Projects Projects
      '';
    };
  };
}
