{
  config,
  options,
  lib,
  ...
}:
let
  cfg = config.credentials;
  opt = options.credentials.mail.description;
in
{
  ## User Credentials ##
  # Warnings
  assertions = [
    {
      assertion = cfg.mail != "";
      message = opt + " must be set";
    }
  ];

  programs.git = {
    settings = {
      user.name = cfg.name;
      user.email = cfg.mail;
      github.user = cfg.name;
    };

    signing = {
      format = "openpgp";
      signByDefault = lib.mkIf (cfg.key != "") true;
      key = lib.mkIf (cfg.key != "") (builtins.substring 24 30 cfg.key);
    };
  };
}
