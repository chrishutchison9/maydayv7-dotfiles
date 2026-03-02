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

    user.homeConfig = {
      home.persist.directories = [ ".config/setzer" ];
      xdg.mimeApps.defaultApplications = util.build.mime {
        latex = [ "org.cvfosammmm.Setzer.desktop" ];
      };
    };
  };
}
