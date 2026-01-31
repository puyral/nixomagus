{ config, lib, pkgs, ... }:
let
  cfg = config.extra.mail-server;
  domain = cfg.domain;
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {

    # --- Host Side Configuration ---

    # From relay.nix (Host side)
    fileSystems."${cfg.remoteStorage.local.base}" = lib.mkIf cfg.remoteStorage.enable {
      device = "${cfg.remoteStorage.remote.ip}:${cfg.remoteStorage.remote.path}";
      fsType = "nfs";
      options = [
        "actimeo=60"
        "rw"
        "noatime"
        "nofail"
      ];
    };

    # Ensure state dirs exist on host
    systemd.tmpfiles.rules = [
      "d /var/lib/mail-server/acme 0755 root root -"
      "d /var/lib/mail-server/dhparams 0755 root root -"
      "d /var/lib/mail-server/dkim 0755 root root -"
    ];

    extra.containers.mailserver = { };

    # Define the container
    containers.mailserver = {
      autoStart = true;
      ephemeral = true;

      bindMounts = {
        "/var/vmail" = {
          hostPath = if cfg.remoteStorage.enable then cfg.remoteStorage.local.storage else "/var/vmail";
          isReadOnly = false;
        };
        # State directories - Persisted on host
        "/var/lib/acme" = { hostPath = "/var/lib/mail-server/acme"; isReadOnly = false; };
        "/var/lib/dhparams" = { hostPath = "/var/lib/mail-server/dhparams"; isReadOnly = false; };
        "/var/dkim" = { hostPath = "/var/lib/mail-server/dkim"; isReadOnly = false; };
        
        # Sops key from host
        "/var/lib/sops.key" = { hostPath = "/etc/ssh/ssh_host_ed25519_key"; isReadOnly = true; };
      };
      
      forwardPorts = [
        { protocol = "tcp"; hostPort = 25; containerPort = 25; }
        { protocol = "tcp"; hostPort = 143; containerPort = 143; }
        { protocol = "tcp"; hostPort = 465; containerPort = 465; }
        { protocol = "tcp"; hostPort = 587; containerPort = 587; }
        { protocol = "tcp"; hostPort = 993; containerPort = 993; }
        { protocol = "tcp"; hostPort = 4190; containerPort = 4190; } # Sieve
      ];

      config = { config, lib, simple-nixos-mailserver, ... }: {
        imports = [
          simple-nixos-mailserver.nixosModules.mailserver
          ./options.nix 
          ./accounts.nix # This defines sops secrets and mail accounts
          ../acme/default.nix
        ];

        # Configure sops inside container
        sops.age.sshKeyPaths = [ "/var/lib/sops.key" ];
        
        # We need to replicate the 'cfg' inside the container
        extra.mail-server = {
             enable = true;
             domain = domain;
        };
        extra.acme = {
             enable = true;
             domain = domain;
        };

        mailserver = {
          enable = true;
          stateVersion = 3;
          fqdn = "mail.${domain}";
          domains = [ domain ];

          certificateScheme = "acme";
          acmeCertificateName = domain;
          
          # From relay.nix
          mailDirectory = "/var/vmail";
          useFsLayout = true;
        };

        services.dovecot2.extraConfig = ''
          mmap_disable = yes
          mail_fsync = always
        '';
      };
    };
  };
}