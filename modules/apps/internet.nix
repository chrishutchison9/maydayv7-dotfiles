{
  config,
  lib,
  pkgs,
  ...
}:
let
  enable = builtins.elem "internet" config.apps.list;
in
{
  ## Internet Apps Configuration ##
  config = lib.mkIf enable {
    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # UBlock Origin
        "djflhoibgkdhkhhcedjiklpkjnoahfmg" # User Agent Switcher
        "lckanjgmijmafbedllaakclkaicjfmnk" # ClearURLs
        "oofgbpoabipfcfjapgnbbjjaenockbdp" # SetupVPN
        "jghecgabfgfdldnmbfkhmffcabddioke" # Volume Booster
        "jaioibhbkffompljnnipmpkeafhpicpd" # Tab Auto Refresh
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
      ];
    };

    environment.systemPackages = with pkgs; [
      brave
      linux-wifi-hotspot
      openfortivpn
      teams-for-linux
      thunderbird
      wasistlos
      zoom-us
    ];

    user.persist = {
      files = [ ".config/zoomus.conf" ];
      directories = [
        ".config/BraveSoftware"
        ".cache/BraveSoftware"
        ".thunderbird"
        ".cache/thunderbird"
        ".config/wasistlos"
        ".local/share/wasistlos"
        ".cache/wasistlos"
        ".zoom"
        ".cache/zoom"
      ];
    };
  };
}
