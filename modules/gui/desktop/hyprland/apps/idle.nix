{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe getExe';
  locker = pkgs.swaylock-effects;
in
{
  ## Idle Timeout
  user.homeConfig.services.swayidle.timeouts =
    let
      lock =
        pre: flag:
        "sh -c 'if ! ${getExe' pkgs.procps "pgrep"} -x swaylock; then ${pre} ${getExe locker} -f ${flag}; fi'";

      audio =
        command:
        "${pkgs.writeShellScript "audio" ''
          ${getExe pkgs.playerctl} status | ${getExe pkgs.gnugrep} Playing
          if [ $? == 1 ]; then ${command}; fi
        ''}"; # Check if audio is playing
      shader = getExe pkgs.hyprshade;
      dpms = "${getExe' config.programs.hyprland.package "hyprctl"} dispatch dpms";
    in
    [
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
        timeout = 500; # Suspend device
        command = audio "${dpms} on && ${lock "" ""} && ${getExe' pkgs.systemd "systemctl"} suspend";
      }
    ];
}
