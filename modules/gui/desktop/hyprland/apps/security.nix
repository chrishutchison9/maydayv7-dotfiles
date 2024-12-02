{
  sys,
  lib,
  pkgs,
  files,
  ...
}: let
  inherit (lib) concatMapStringsSep getExe getExe';
  locker = pkgs.swaylock-effects;
in {
  # Locker
  stylix.targets.swaylock = {
    enable = true;
    useImage = true;
  };

  programs.swaylock = {
    enable = true;
    package = locker;
    settings = {
      clock = true;
      indicator = true;
      font = sys.stylix.fonts.sansSerif.name;
      effect-vignette = "0.3:1";
    };
  };

  # Idle Daemon
  services.swayidle = let
    pause = "${getExe pkgs.playerctl} pause -a";
    lock = pre: flag: "sh -c 'if ! ${getExe' pkgs.procps "pgrep"} -x swaylock; then ${pre}; ${getExe locker} -f ${flag}; fi'";
  in {
    enable = true;
    extraArgs = ["-w"];
    events = [
      {
        event = "before-sleep";
        command = lock pause "";
      }
      {
        event = "lock";
        command = lock pause "--fade-in 0.2 --grace 15 --grace-no-mouse";
      }
    ];

    timeouts = let
      audio = command: "${pkgs.writeShellScript "audio" ''
        ${getExe' pkgs.pipewire "pw-cli"} info all | ${getExe pkgs.gnugrep} running
        if [ $? == 1 ]; then ${command}; fi
      ''}"; # Check if audio is playing
      shader = getExe pkgs.hyprshade;
      dpms = "${getExe' sys.programs.hyprland.package "hyprctl"} dispatch dpms";
    in [
      {
        timeout = 240; # Dim display
        command = audio "${shader} on dim";
        resumeCommand = "${shader} off";
      }
      {
        timeout = 300; # Turn off display
        command = audio "${dpms} off";
        resumeCommand = "${dpms} on";
      }
      {
        timeout = 500; # Suspend then Hibernate device
        command = audio "${dpms} on && ${lock "" ""} && ${getExe' pkgs.systemd "systemctl"} suspend-then-hibernate ";
      }
    ];
  };

  # Logout
  programs.wlogout = {
    enable = true;
    style =
      files.hyprland.wlogout
      + ''
        ${concatMapStringsSep "\n" (
            name: ''
              #${name} {
                background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/${name}.png"));
              }
            ''
          ) [
            "lock"
            "logout"
            "suspend"
            "hibernate"
            "shutdown"
            "reboot"
          ]}
      '';
  };
}
