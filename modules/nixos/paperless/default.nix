{
  config,
  lib,
  pkgs,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.paperless;
  name = "paperless";
  port = 28981;
  dataDir = cfg.dataDir;
  user = name;
in
{
  options.extra.paperless = with lib; {
    enable = mkEnableOption name;
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/${name}";
    };
    mediaDir = mkOption {
      type = types.path;
      default = "${config.vars.Zeno.mountPoint}/paperless";
    };
    incommingDir = mkOption {
      type = types.path;
      default = "${config.vars.Zeno.mountPoint}/administratif/paperless";
    };
    backupDir = mkOption {
      type = types.path;
      default = "${config.vars.Zeno.mountPoint}/administratif/backup";
    };
    ai = {
      enable = mkEnableOption "paperless-ai integration";
      port = mkOption {
        type = types.port;
        default = 3000;
        description = "Port for paperless-ai web UI";
      };
      ragPort = mkOption {
        type = types.port;
        default = 8000;
        description = "Port for paperless-ai RAG service";
      };
      ollamaUrl = mkOption {
        type = types.str;
        default = "http://${config.containers.${name}.hostAddress}:11434";
        description = "URL of the Ollama server";
      };
      ollamaModel = mkOption {
        type = types.str;
        default = "llama3.2";
        description = "Ollama model to use";
      };
      tokenFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "File containing the Paperless-ngx API token";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    containers.${name} = {
      bindMounts = {
        "/data" = {
          hostPath = dataDir;
          isReadOnly = false;
        };
        "/media" = {
          hostPath = cfg.mediaDir;
          isReadOnly = false;
        };
        "/incomming" = {
          hostPath = cfg.incommingDir;
          isReadOnly = false;
        };
        "/backup" = {
          hostPath = cfg.backupDir;
          isReadOnly = false;
        };
        "/ai-data" = lib.mkIf cfg.ai.enable {
          hostPath = "${cfg.dataDir}/ai";
          isReadOnly = false;
        };
        "/ai-token" = lib.mkIf (cfg.ai.enable && cfg.ai.tokenFile != null) {
          hostPath = cfg.ai.tokenFile;
          isReadOnly = true;
        };
      };
      autoStart = true;
      ephemeral = true;
      config =
        { ... }:
        let
          paperless = pkgs.paperless-ngx;
          paperless-ai-pkg = pkgs-self.paperless-ai;
        in
        {
          environment.systemPackages =
            with pkgs;
            [
              paperless
            ]
            ++ lib.optional cfg.ai.enable paperless-ai-pkg;

          systemd.services.paperless-ai-rag = lib.mkIf cfg.ai.enable {
            description = "Paperless-AI RAG service";
            after = [
              "network.target"
              "paperless.service"
            ];
            wantedBy = [ "multi-user.target" ];
            environment = {
              PAPERLESS_API_URL = "http://localhost:${toString port}/api";
              AI_PROVIDER = "ollama";
              OLLAMA_API_URL = cfg.ai.ollamaUrl;
              OLLAMA_MODEL = cfg.ai.ollamaModel;
              HOME = "/ai-data";
              PAPERLESS_USERNAME = "simon";
            };
            serviceConfig = {
              ExecStart = "${paperless-ai-pkg}/bin/paperless-ai-rag --host 127.0.0.1 --port ${toString cfg.ai.ragPort} --initialize";
              WorkingDirectory = "/ai-data";
              Restart = "always";
              EnvironmentFile = lib.optional (cfg.ai.tokenFile != null) "/ai-token";
            };
          };

          systemd.services.paperless-ai = lib.mkIf cfg.ai.enable {
            description = "Paperless-AI web service";
            after = [ "paperless-ai-rag.service" ];
            wantedBy = [ "multi-user.target" ];
            environment = {
              PAPERLESS_AI_PORT = toString cfg.ai.port;
              RAG_SERVICE_URL = "http://localhost:${toString cfg.ai.ragPort}";
              RAG_SERVICE_ENABLED = "true";
              OLLAMA_API_URL = cfg.ai.ollamaUrl;
              OLLAMA_MODEL = cfg.ai.ollamaModel;
              PAPERLESS_API_URL = "http://localhost:${toString port}/api";
              AI_PROVIDER = "ollama";
              HOME = "/ai-data";
              PAPERLESS_USERNAME = "simon";
            };
            serviceConfig = {
              # We run it directly with node since the package includes it.
              ExecStart = "${pkgs.nodejs}/bin/node ${paperless-ai-pkg}/lib/node_modules/paperless-ai/server.js";
              WorkingDirectory = "/ai-data";
              Restart = "always";
              EnvironmentFile = lib.optional (cfg.ai.tokenFile != null) "/ai-token";
            };
          };

          services.paperless = {
            inherit port user;
            # package =  pkgs.paperless-ngx.overrideAttrs (final: prev: {doTest = false;});
            # package = extra-pkgs.paperless-nixpkgs.paperless-ngx;
            package = paperless;
            enable = true;
            dataDir = "/data";
            mediaDir = "/media";
            consumptionDir = "/incomming";
            consumptionDirIsPublic = true;
            passwordFile = ./secrets/PASSWORD;
            settings = rec {
              PAPERLESS_ADMIN_USER = "simon";
              PAPERLESS_CONSUMER_IGNORE_PATTERN = [
                "*/.DS_Store"
                "._*"
                "desktop.ini"
              ];
              PAPERLESS_CONSUMER_RECURSIVE = true;
              PAPERLESS_OCR_LANGUAGE = "fra+deu+eng";
              PAPERLESS_OCR_USER_ARGS = {
                optimize = 1;
                pdfa_image_compression = "lossless";
              };

              PAPERLESS_TASK_WORKERS = 2;
              PAPERLESS_TIME_ZONE = "Europe/Vienna";

              # PAPERLESS_OCR_SKIP_ARCHIVE_FILE = "with_text";
              PAPERLESS_TRUSTED_PROXIES = config.containers.${name}.hostAddress;
              PAPERLESS_URL = "https://${name}.${config.networking.traefik.baseDomain}";
              # PAPERLESS_CSRF_TRUSTED_ORIGINS = "${PAPERLESS_URL},${PAPERLESS_TRUSTED_PROXIES}";
            };
            address = "0.0.0.0";

            exporter = {
              enable = true;
              directory = "/backup";
              settings = {
                compare-checksums = true;
                delete = true;
                no-color = true;
                no-progress-bar = true;
                split-manifest = true;
              };
            };
          };
          users.groups.${user}.gid = lib.mkForce config.users.groups.${user}.gid;
          users.groups.syncthing = {
            members = [ user ];
            gid = config.users.groups.syncthing.gid;
          };
        };
    };
    extra.containers.${name} = {
      traefik = [
        {
          inherit port;
          enable = true;
        }
      ]
      ++ lib.optional cfg.ai.enable {
        name = "${name}-ai";
        port = cfg.ai.port;
        enable = true;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}/ai 0755 root root -"
    ];
  };
}
