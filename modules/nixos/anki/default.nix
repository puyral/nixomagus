{ lib, config, ... }:
let
  cfg = config.extra.anki;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}/data 0755 root root -"
      "d ${cfg.dataDir}/service 0755 root root -"
    ];


    containers.anki = {
      bindMounts = {
        "/data" = {
          hostPath = "${cfg.dataDir}/data";
          isReadOnly = false;
        };
        "/var/lib/anki-sync-server" = {
          hostPath = "${cfg.dataDir}/service";
          isReadOnly = false;
        };
        "/sops" = {
          hostPath = cfg.sopsKey;
          isReadOnly = true;
        };
      };
      autoStart = true;
      ephemeral = true;

      config =
        { config, ... }:
        {
          services.anki-sync-server = {
            enable = true;
            port = cfg.port;
            baseDirectory = "/data";
            users = builtins.map (u: {
              username = u;
              passwordFile = config.sops.secrets."${u}".path;
            }) cfg.users;
          };

          sops.age.sshKeyPaths = [ "/sops" ];
          sops.secrets = lib.genAttrs cfg.users (name: {
              sopsFile = cfg.passwords;
              format = "json";
              key = name;
          });
        };
    };

    extra.containers.anki = {
      # vpn = true;

      traefik = [
        {
          port = cfg.port;
          name = cfg.subdomain;
          enable = true;
          # providers = cfg.providers;
          # address = "100.64.0.8";
        }
      ];
    };
  };
}
