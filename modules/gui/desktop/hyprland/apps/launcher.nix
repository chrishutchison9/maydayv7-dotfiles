{
  config,
  util,
  inputs,
  files,
  ...
}:
{
  ## Launcher Configuration
  user.homeConfig = {
    imports = [ inputs.hyprshell.homeModules.hyprshell ];
    programs.hyprshell = {
      enable = true;
      systemd.enable = true;
      style = util.build.theme {
        inherit (config.lib.stylix) colors;
        file = files.hyprland.hyprshell;
      };

      declarative = true;
      settings = {
        layerrules = false;

        launcher = {
          enable = true;
          default_terminal = "kitty";
          width = 700;
          max_items = 10;
          plugins = {
            applications = {
              cache = 4;
              execs = true;
            };
            websearch.engines = [
              {
                url = "https://www.google.com/search?q={}";
                name = "Google";
                key = "g";
              }
            ];
          };
        };

        window = {
          scale = 9.0;
          workspaces_per_row = 3;
          strip_html_from_workspace_title = true;

          overview = {
            open = {
              modifier = "super";
              key = "tab";
            };
            navigate = {
              forward = "tab";
              reverse = "Mod(shift)";
            };
            filter = {
              hide = false;
              by = [ ];
            };
          };

          switcher = {
            open.modifier = "alt";
            navigate = {
              forward = "tab";
              reverse = "Mod(shift)";
            };
            filter = {
              hide = true;
              by = [ "current_workspace" ];
            };
          };
        };
      };
    };
  };
}
