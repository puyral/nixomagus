{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.extra.audioCpp;

  modelEntry =
    m:
    {
      id = m.id;
      path = m.model;
      family = m.family;
      task = m.task;
      mode = m.mode;
    } // lib.optionalAttrs (m.audioDefaultRequestOptions != { }) {
    default_request_options = m.audioDefaultRequestOptions;
  };

  serverJson = pkgs.writeText "audiocpp-server.json" (builtins.toJSON ({
    host = "127.0.0.1";
    lazy_load = true;
    models = map modelEntry cfg.models;
  } // cfg.extraOptions));

in
{
  options.extra.audioCpp = with lib; {
    enable = mkEnableOption "standalone audio.cpp server";

    package = mkPackageOption pkgs-unstable "audio-cpp" { };

    host = mkOption {
      default = "0.0.0.0";
      type = types.str;
    };

    port = mkOption {
      default = 8083;
      type = types.port;
    };

    backend = mkOption {
      default = "cpu";
      type = types.enum [
        "cpu"
        "cuda"
        "hip"
        "rocm"
        "vulkan"
        "metal"
      ];
    };

    openFirewall = mkOption {
      default = true;
      type = types.bool;
    };

    models = mkOption {
      default = [ ];
      type = types.listOf (
        types.submodule {
          options = {
            id = mkOption { type = types.str; };
            model = mkOption { type = types.str; };
            family = mkOption { type = types.str; };
            task = mkOption { type = types.str; };
            mode = mkOption {
              default = "offline";
              type = types.str;
            };
            audioDefaultRequestOptions = mkOption {
              default = { };
              type = types.attrsOf types.str;
            };
          };
        }
      );
    };

    extraOptions = mkOption {
      type = types.attrs;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.audiocpp = {
      description = "audio.cpp inference server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        # CWD = package root so request-time model_specs discovery finds
        # model_specs/<family>.json (the audio.cpp server only looks for those
        # relative to the working directory for per-request contract validation).
        WorkingDirectory = "${cfg.package}";
        ExecStart = "${lib.getExe' cfg.package "audiocpp_server"} --config ${serverJson} --host ${cfg.host} --port ${toString cfg.port} --backend ${cfg.backend} --no-ui --log";
        Restart = "on-failure";
        ProcSubset = "all";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
