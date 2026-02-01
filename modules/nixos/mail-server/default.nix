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
in
{
  imports = [
    ./options.nix
    ./relay.nix
  ];

  config = lib.mkIf cfg.enable {

    # Ensure state dirs exist on host
    # systemd.tmpfiles.rules = [
    #   "d /var/lib/mail-server/acme 0755 root root -"
    #   "d /var/lib/mail-server/dhparams 0755 root root -"
    #   "d /var/lib/mail-server/dkim 0755 root root -"
    # ];

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
              isReadOnly = true;
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
            isReadOnly = true;
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

            # From relay.nix
            useFsLayout = true;

            indexDir = "/var/lib/dovecot/indices";
            mailDirectory = mail;
            sieveDirectory = "/var/lib/sieve";
          };

          services.dovecot2.extraConfig = ''
            mmap_disable = yes
            mail_fsync = always
          '';
        };
    };
  };
}
