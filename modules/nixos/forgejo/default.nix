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
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    containers.forgejo = {
      bindMounts = {
        "/data" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
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

                LFS_MAX_FILE_SIZE = 0;
              };
              service = {
                DISABLE_REGISTRATION = true;
              };

              session = {
                COOKIE_SECURE = true;
              };
              repository = {
                DEFAULT_PRIVATE = true;
                ENABLE_PUSH_CREATE_USER = true;
                ENABLE_PUSH_CREATE_ORG = true;
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
          extraConfig = ''
            client_max_body_size 0;  
            # Forgejo keeps a permanent SSE stream open at /user/events (SharedWorker).
            # Don't buffer it, and don't kill it on the 60s idle timeout, or the web UI
            # intermittently hangs. (text/event-stream is already excluded from gzip/zstd.)
            proxy_buffering off;
            proxy_cache off;
            proxy_read_timeout 1h;
            proxy_send_timeout 1h;
          '';
        }
      ];
    };
  };

}
