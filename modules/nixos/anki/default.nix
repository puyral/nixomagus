{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.anki;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    containers.anki = {
      bindMounts = {
        "/data" = {
          hostPath = "${cfg.dataDir}";
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

          systemd.services.anki-sync-server = {
            serviceConfig = {
              User = "anki-sync-server";

              ReadWritePaths = [ "/data" ];

              ExecStartPre = [
                "+${pkgs.coreutils}/bin/chown -R anki-sync-server:anki-sync-server /data"
              ];
            };
          };
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
