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
    lock = pre: post: "sh -c 'if ! ${getExe' pkgs.procps "pgrep"} -x swaylock; then ${pre}; ${getExe locker} -f ${post}; fi'";
  in {
    enable = true;
    extraArgs = ["-w"];
    systemdTarget = "hyprland-session.target";

    events = [
      {
        event = "before-sleep";
        command = lock "" "";
      }
      {
        event = "lock";
        command = lock "${getExe pkgs.playerctl} pause -a" "--fade-in 0.2 --grace 15 --grace-no-mouse";
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

  # Authorization Agent
  systemd.user.services.polkit = {
    Unit.Description = "Polkit Authentication";

    Install = {
      WantedBy = ["graphical-session.target"];
      Wants = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
