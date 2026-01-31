{ config, lib, ... }:
let
  cfg = config.extra.mail-server;
  domain = cfg.domain;
in
{
  imports = [
    ./options.nix
    ./accounts.nix
  ];

  # mostly pulled straight out of https://nixos-mailserver.readthedocs.io/en/latest/setup-guide.html

  config = lib.mkIf cfg.enable {

    mailserver = {
      enable = true;
      stateVersion = 3;
      fqdn = "mail.${domain}";
      domains = [ domain ];

      certificateScheme = "acme";
      acmeCertificateName = domain;
    };
  };
}
