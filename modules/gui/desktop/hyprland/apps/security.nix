{
  config,
  lib,
  util,
  pkgs,
  files,
  ...
}: let
  inherit (lib) getExe getExe';
  locker = pkgs.swaylock-effects;
in {
  ## Security Configuration
  # User Authentication
  security = {
    soteria.enable = true;
    pam.services.swaylock.text = "auth include login";
  };

  user.homeConfig = {
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
        font = config.stylix.fonts.sansSerif.name;
        effect-vignette = "0.3:1";
      };
    };

    # Idle Daemon
    services.swayidle = let
      pause = "${getExe pkgs.playerctl} pause -a;";
      lock = pre: flag: "sh -c 'if ! ${getExe' pkgs.procps "pgrep"} -x swaylock; then ${pre} ${getExe locker} -f ${flag}; fi'";
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
          ${getExe pkgs.playerctl} status | ${getExe pkgs.gnugrep} Playing
          if [ $? == 1 ]; then ${command}; fi
        ''}"; # Check if audio is playing
        shader = getExe pkgs.hyprshade;
        dpms = "${getExe' config.programs.hyprland.package "hyprctl"} dispatch dpms";
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
          timeout = 500; # Suspend device
          command = audio "${dpms} on && ${lock "" ""} && ${getExe' pkgs.systemd "systemctl"} suspend";
        }
      ];
    };

    # Logout
    programs.wlogout = {
      enable = true;
      style = util.build.theme {
        inherit (config.lib.stylix) colors;
        file = files.hyprland.wlogout;
      };

      layout = [
        {
          label = "lock";
          action = "loginctl lock-session";
          text = "";
          keybind = "l";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "";
          keybind = "u";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "";
          keybind = "h";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "";
          keybind = "r";
        }
      ];
    };
  };
}
