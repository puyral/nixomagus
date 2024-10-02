{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.extra.mail.enable = mkEnableOption "sendmail";

  config.programs.msmtp = mkIf (config.extra.mail.enable) {
    enable = true;
    accounts.default = (
      {
        tls = true;
        auth = true;
        host = "smtp.gmail.com";
        port = 587;
      }
      // (import ./secrets/credentials.nix) pkgs config.networking.hostName
    );
  };
}
