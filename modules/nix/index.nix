{
  config,
  lib,
  inputs,
  ...
}:
{
  options.nix.index = lib.mkEnableOption "Enable Package Indexer";

  ## Package Indexer ##
  config = lib.mkIf config.nix.index {
    user.homeConfig = {
      imports = [ inputs.index.homeModules.nix-index ];
      programs = {
        nix-index.enable = true;
        nix-index-database.comma.enable = true;
      };
    };
  };
}
