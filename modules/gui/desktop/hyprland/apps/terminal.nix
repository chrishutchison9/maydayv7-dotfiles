{
  pkgs,
  theme,
  ...
}: {
  ## Terminal Configuration
  gui.launcher.terminal = "kitty";
  user.homeConfig = {
    programs.kitty = {
      enable = true;
      themeFile = with theme; "${name-alt}-${variant-alt}";
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "kitty_mod+f" = "launch --allow-remote-control kitty +kitten search/search.py @active-kitty-window-id";
      };

      settings = {
        kitty_mod = "ctrl+shift";
        placement_strategy = "center";

        copy_on_select = "clipboard";
        scrollback_lines = 10000;

        enable_audio_bell = "no";
        visual_bell_duration = "0.1";
      };
    };

    wayland.windowManager.hyprland.settings.misc.swallow_regex = "^(kitty)$";
    stylix.targets.kitty = {
      enable = true;
      variant256Colors = true;
    };

    home.file = {
      ".config/kitty/search".source = pkgs.custom.kitty-search;
      ".config/xfce4/helpers.rc".text = ''
        TerminalEmulator=kitty
        TerminalEmulatorDismissed=true
      '';
    };
  };
}
