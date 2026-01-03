_: {
  ## Website Configuration ##
  perSystem =
    { lib, pkgs, ... }:
    {
      # Website
      packages.website = pkgs.callPackage ./. { inherit pkgs; };

      # 'git' Frontend
      apps.build-stagit = {
        type = "app";
        program = "${pkgs.callPackage ./git { inherit lib pkgs; }}/bin/build-stagit";
      };

      # Development Shell
      devShells.website = import ./shell.nix { inherit pkgs; };

      # Formatting Errors
      treefmt.config.programs.prettier.excludes = [
        "site/templates/macros/edit.html"
        "site/templates/macros/head.html"
        "site/templates/macros/javascript.html"
        "site/templates/macros/menu.html"
        "site/templates/macros/posts.html"
        "site/templates/tags/list.html"
      ];
    };
}
