{
  config,
  pkgs-unstable,
  pkgs,
  lib,
  ...
}:
let
  uiPort = 2283;
  gconfig = config;
  cfg = config.extra.forgejo;
in
{
  imports = [./options.nix];
  config = lib.mkIf cfg.enable {
    containers.forgejo = {
      bindMounts = {
        "/data" = {
          hostPath = cfg.dataDir;
          isReadOnly =  false;
        };
      };
      autoStart = true;
      ephemeral = true;
      forwardPorts = [
        {
          protocol = "tcp";
          hostPort = cfg.sshPort;
          containerPort = cfg.sshListenPort;
        }
      ];

      config =
        { ... }:
        {
          services.forgejo = {
            enable = true;
            stateDir = "/data";
            settings = {
              # mailer = {
              #   ENABLED = true;
              #   PROTOCOL = "sendmail";
              #   FROM = "do-not-reply@example.org";
              #   SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
              # };
              server = rec {
                HTTP_PORT = uiPort;
                # External port shown in clone URLs (what clients connect to).
                SSH_PORT = cfg.sshPort;
                # Run forgejo's built-in SSH server inside the container.
                # By default the nixpkgs module expects an external sshd to
                # handle SSH (via authorized_keys command), which doesn't work
                # in a container. Enabling this makes forgejo run its own SSH
                # server.
                START_SSH_SERVER = true;
                # The hardened forgejo service has no CAP_NET_BIND_SERVICE, so
                # it cannot bind privileged ports (<1024). Listen on a high
                # port inside the container; the host forwards sshPort -> this.
                SSH_LISTEN_PORT = cfg.sshListenPort;
                DOMAIN = "git.puyral.fr";
                ROOT_URL = "https://${DOMAIN}/";
              };
              service = {
                DISABLE_REGISTRATION = true;
              };

              session = {
                COOKIE_SECURE =true;
              };
            };
            lfs = {
              enable = true;
            };
            dump = {
              enable = true;
            };
          };
        };
    };
    extra.containers.forgejo = {
      nginx = [
        {
          port = uiPort;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.providers;
        }
      ];
    };
  };

}