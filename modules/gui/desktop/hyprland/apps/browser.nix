{theme, ...}: {
  ## Browser Configuration
  apps.list = ["firefox"];
  user.homeConfig = {
    programs.firefox = {
      policies.ExtensionSettings = {
        name = with theme; "${name}-${variant}-${accent}";
        value = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/{d49033ac-8969-488c-afb0-5cdb73957f41}/latest.xpi";
        };
      };
    };

    home.file.".mozilla/firefox/default/chrome/userChrome.css".text = ''
      #TabsToolbar {
        -moz-window-dragging: no-drag;
      }
    '';
  };
}
