{
  config,
  lib,
  ...
}:
{
  ## Roblox ##
  config = lib.mkIf (builtins.elem "roblox" config.apps.games) {
    warnings = [ "Flatpak support is required to run Roblox" ];
    apps.list = [ "flatpak" ];
    services.flatpak.packages = [
      {
        appId = "org.vinegarhq.Sober";
        origin = "flathub";
      }
    ];
  };
}
