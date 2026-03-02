{
  inputs,
  lib,
  util,
  ...
}:
let
  inherit (util.map) modules;
  inherit (lib) mkForce mkOption types;
in
{
  ## HARDWARE Configuration ##
  imports = modules.list ./.;

  options.hardware = with types; {
    modules = mkOption {
      description = "List of Modules imported from 'inputs.hardware'";
      type = listOf (enum (attrNames inputs.hardware.nixosModules));
      default = [ ];
    };

    support = mkOption {
      description = "List of Additional Supported Hardware";
      type = listOf (enum (modules.name ./.));
      default = [ ];
    };
  };

  config = {
    specialisation.powersave.configuration = {
      system.nixos.label = "special.powersave";
      gui.fancy = mkForce false;
      hardware.cpu.mode = mkForce "powersave";
    };
  };
}
