{
  config,
  util,
  files,
  ...
}:
{
  ## Launcher Configuration
  user = {
    persist.directories = [
      ".local/share/hyprshell"
      ".cache/hyprshell"
    ];

    homeConfig = {
      services.hyprshell = {
        enable = true;
        systemd.enable = true;
        style = util.build.theme {
          inherit (config.lib.stylix) colors;
          file = files.hyprland.hyprshell;
        };

        settings.windows = {
          scale = 9.0;
          items_per_row = 3;

          overview = {
            modifier = "super";
            key = "tab";

            launcher = {
              launch_modifier = "alt";
              default_terminal = "kitty";
              width = 700;
              max_items = 4;
              show_when_empty = true;
              plugins = {
                applications = {
                  run_cache_weeks = 4;
                  show_execs = true;
                  show_actions_submenu = true;
                };
                websearch.engines = [
                  {
                    url = "https://www.google.com/search?q={}";
                    name = "Google";
                    key = "g";
                  }
                  {
                    url = "https://en.wikipedia.org/wiki/Special:Search?search={}";
                    name = "Wikipedia";
                    key = "w";
                  }
                ];
              };
            };
          };

          switch = {
            modifier = "alt";
            filter_by = [ "current_workspace" ];
          };
        };
      };
    };
  };
}
