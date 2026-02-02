{
  config,
  lib,
  simple-nixos-mailserver,
  ...
}:
let
  cfg = config.extra.mail-server;
  mail = "/var/vmail";
  sopsKey = "/etc/sops";
  acmeConfig = config.extra.acme;
  hostConfig = config;
in
{
  imports = [
    ./options.nix
    ./relay.nix
  ];

  config = lib.mkIf cfg.enable {

    extra.containers.mailserver = { };

    # Define the container
    containers.mailserver = {
      autoStart = true;
      ephemeral = true;

      bindMounts =
        let
          mkVarLib = p: {
            name = "/var/lib/${p}";
            value = {
              hostPath = "${cfg.dirs.data}/${p}";
              isReadOnly = false;
            };
          };
          mkAll = with builtins; list: listToAttrs (map mkVarLib list);
        in
        {
          "${sopsKey}" = {
            hostPath = cfg.sopsKey;
            isReadOnly = true;
          };
          "${cfg.dirs.acme}" = {
            hostPath = cfg.dirs.acme;
            isReadOnly = false;
          };
          "${mail}" = {
            hostPath = "${cfg.dirs.data}/${cfg.dirs.mails}";
            isReadOnly = false;
          };
        }
        // (mkAll [
          # "dhparams"
          "dkim"
          "postfix"
          "dovecot"
          "sieve"
          "redis-rspamd"
          "rspamd"
        ]);

      forwardPorts =
        with builtins;
        map
          (port: {
            protocol = "tcp";
            hostPort = port;
            containerPort = port;
          })
          [
            25
            143
            465
            587
            993
            4190
          ];

      config =
        { ... }:
        {
          imports = [
            simple-nixos-mailserver.nixosModules.mailserver
            ./accounts.nix # This defines sops secrets and mail accounts
            ./options.nix
            ../acme
          ];

          extra.acme = acmeConfig;
          extra.mail-server = hostConfig.extra.mail-server;
          security.acme.defaults.renewInterval = "yearly";

          # Configure sops inside container
          sops.age.sshKeyPaths = [ sopsKey ];

          mailserver = {
            enable = true;
            stateVersion = 3;
            fqdn = cfg.fqdn;
            domains = cfg.domains;

            certificateScheme = "acme";
            acmeCertificateName = cfg.mainDomain;

            dmarcReporting.enable = true;

            # From relay.nix
            useFsLayout = true;

            indexDir = "/var/lib/dovecot/indices";
            mailDirectory = mail;
            sieveDirectory = "/var/lib/sieve";
            dkimKeyDirectory = "/var/lib/dkim";
          };

          services.dovecot2.extraConfig = ''
            mmap_disable = yes
            mail_fsync = always
          '';
        };
    };
  };
}
