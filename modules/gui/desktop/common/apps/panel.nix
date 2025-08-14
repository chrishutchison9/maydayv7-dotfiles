{ pkgs, ... }:
{
  ## Panel Configuration
  user.homeConfig = {
    stylix.targets.waybar = {
      enable = true;
      font = "sansSerif";
      addCss = false;
    };

    home.packages = [ pkgs.wttrbar ];
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      package = pkgs.unstable.waybar;
    };
  };
}
