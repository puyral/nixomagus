{ lib, config, pkgs-unstable, ... }:
with lib;
let
  cfg = config.extra.llm;
in
{
  options.extra.llm = {
    enable = mkEnableOption "llm";

    acceleration = mkOption {
      description = "What interface to use for hardware acceleration. When null, auto-detects based on hardware.";
      default = null;
      type = types.nullOr (
        types.enum [
          false
          "rocm"
          "cuda"
          "vulkan"
          "intel"
        ]
      );
    };

    data = mkOption { # <- this changed. Need to adapts the configs to reflect how things used to be
      type = types.path;
      default = "/var/lib";
    };

    defaultLLM = mkOption {
      type = types.str;
      default = "llama3.2";
    };

    llama-swap = {
      enable = mkEnableOption "llama-swap model manager";

      llamaCppPackage = mkPackageOption pkgs-unstable "llama-cpp";

      port = mkOption {
        description = "Port for llama-swap";
        default = 8082;
        type = types.port;
      };

      host = mkOption {
        description = "Host for llama-swap";
        default = "0.0.0.0";
        type = types.str;
      };

      healthCheckTimeout = mkOption {
        description = "Timeout for health checks in seconds";
        default = 60;
        type = types.int;
      };

      models = mkOption {
        description = "List of models to manage with llama-swap";
        default = [ ];
        type = types.listOf (
          types.submodule {
            options = {
              id = mkOption {
                description = "Model identifier (used as the key in llama-swap config)";
                type = types.str;
              };
              model = mkOption {
                description = "Model name/identifier or path to GGUF file";
                type = types.str;
              };
              nGpuLayers = mkOption {
                description = "Number of GPU layers (-1 for all)";
                default = -1;
                type = types.int;
              };
              contextSize = mkOption {
                description = "Context size (null for default)";
                default = null;
                type = types.nullOr types.int;
              };
              parallelSequences = mkOption {
                description = "Number of parallel sequences (-np option, null for default)";
                default = null;
                type = types.nullOr types.int;
              };
              aliases = mkOption {
                description = "Alternative names for the model";
                default = [ ];
                type = types.listOf types.str;
              };
              concurrencyLimit = mkOption {
                description = "Maximum concurrent requests";
                default = null;
                type = types.nullOr types.int;
              };
              extraArgs = mkOption {
                description = "Additional arguments to pass to llama-server";
                default = [ ];
                type = types.listOf types.str;
              };
            };
          }
        );
      };
    };

    ollama = {
      enable = mkEnableOption "Ollama" // {
        default = true;
      };

      data = mkOption { # <- same
        description = "Where to put the models";
        default = "${cfg.data}/ollama";
        type = types.path;
      };

      port = mkOption {
        description = "Port for Ollama";
        default = 11434;
        type = types.port;
      };

      host = mkOption {
        description = "Host for Ollama";
        default = "0.0.0.0";
        type = types.str;
      };
    };

    open-webui = {
      enable = mkEnableOption "Open WebUI" // {
        default = true;
      };

      port = mkOption {
        description = "Port for Open WebUI";
        default = 8081;
        type = types.port;
      };

      data = mkOption { # <- same
        description = "Where to put the models";
        default = "${cfg.data}/open-webui";
        type = types.path;
      };

      host = mkOption {
        description = "Host for Open WebUI";
        default = "0.0.0.0";
        type = types.str;
      };
    };
  };
}
