{lib, config, ...}: let cfg = config.extra.anki; in {
  imports = [./options.nix];
  config = lib.mkIf cfg.enable {
    containers.anki = {
      bindMounts = {
        "/data" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
        "/sops" = {
          host = cfg.sopsKey;
          isReadOnly = true;
        };
      };
      autoStart = true;
      ephemeral = true;

      config = {config, ...}:{
        services.anki-sync-server = {
          enable = true;
          port = cfg.port;
          baseDirectory = "/data";
          users = builtins.map (u: {
            username = u;
            passwordFile = config.sops.secrets."passwordFile/${u}".path;
          }) cfg.users;
        };

                  sops.age.sshKeyPaths = [ "/sops" ];
          sops.secrets = lib.genAttrs (name: {
    name = "passwordFile/${name}";
    value = {
      sopsFile = cfg.passwords;
      format = "json";
      key = name;
    };
  }) cfg.users;
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