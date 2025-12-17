{
  config,
  lib,
  util,
  pkgs,
  ...
}:
let
  enable = builtins.elem "latex" config.apps.list;
in
{
  ## LaTeX Configuration ##
  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      texliveFull
      setzer
    ];

    user = {
      persist.directories = [ ".config/setzer" ];
      homeConfig.xdg.mimeApps.defaultApplications = util.build.mime {
        latex = [ "org.cvfosammmm.Setzer.desktop" ];
      };
    };
  };
}
