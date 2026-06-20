_: {
  nixos = {
    config,
    lib,
    pkgs,
    ...
  }: {
    boot = {
      plymouth.extraConfig = "DeviceScale=2";

      # ! # https://gitlab.freedesktop.org/drm/amd/-/issues/3388
      kernelParams = lib.mkIf (config.hardware.cpu.mode == "performance") [
        "amdgpu.dcdebugmask=0x10"
        "usbcore.autosuspend=-1"
      ];
    };

    services = {
      fwupd.enable = true;

      # Remap Keys
      udev.extraHwdb = ''
        evdev:name:Asus Keyboard:*
          KEYBOARD_KEY_7003f=print # F6 -> PrtSc Key
      '';
    };

    # ASUS Software
    services.asusd = {
      enable = true;
      asusdConfig.text = builtins.readFile ./asusd.ron;
      auraConfigs."19b6".text = builtins.readFile ./aura.ron;
    };

    # VPN
    services.cloudflare-warp = {
      enable = true;
      openFirewall = true;
    };

    ## Development
    environment = {
      persist.directories = [config.services.cloudflare-warp.rootDir];
      systemPackages = with pkgs; [
        cloudflared
        gcc
        github-copilot-cli
        (mongodb-compass.overrideAttrs (oldAttrs: {
          postFixup =
            (oldAttrs.postFixup or "")
            + ''
              wrapProgram $out/bin/mongodb-compass \
                --add-flags "--password-store=gnome-libsecret --ignore-additional-command-line-flags"
            '';
        }))

        # Node
        nodejs
        npm-check-updates
        pnpm
      ];
    };

    networking.firewall = {
      allowedUDPPorts = [7777];
      allowedTCPPorts = [7777];
    };
  };

  home = {lib, ...}: {
    home.persist.directories = [
      ".copilot"
      ".mongodb"
      ".npm"
      ".config/rog"
      ".config/MongoDB Compass"
      ".local/share/cloudflare-warp-gui"
    ];

    # Keybinds
    wayland.windowManager.hyprland.settings.bind = let
      inline = lib.generators.mkLuaInline;
      locked = {locked = true;};
    in [
      {_args = ["XF86Launch3" (inline ''hl.dsp.exec_cmd("asusctl aura -n")'') locked];}
      {_args = ["XF86Launch4" (inline ''hl.dsp.exec_cmd("asusctl profile -n")'') locked];}
    ];

    # Development
    home = {
      sessionPath = ["$HOME/.npm/packages/bin"];
      file.".npmrc".text = ''
        prefix=''${HOME}/.npm/packages
        cache=''${HOME}/.npm/cache
      '';
    };
    programs.ssh.settings."ssh.codingclub.in".ProxyCommand = "cloudflared access ssh --hostname %h";
  };
}
