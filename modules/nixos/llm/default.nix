{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.extra.llm;
in
{

  options.extra.llm = with lib; {
    enable = mkEnableOption "llm";

    acceleration = mkOption {
      description = "What interface to use for hardware acceleration.";
      default = null;
      type = types.nullOr (
        types.enum [
          false
          "rocm"
          "cuda"
          "vulkan"
        ]
      );
    };
    data = mkOption {
      description = "Where to put the models";
      default = "/var/lib/ollama";
      type = types.str;
    };
    defaultLLM = mkOption {
      type = types.str;
      default = "llama3.2";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable OLLAMA
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      acceleration = cfg.acceleration;
      home = cfg.data;
      openFirewall = true;
      user = "ollama";
    };

    services.open-webui = {
      enable = true;
      port = 8081;
      openFirewall = true;
      host = "0.0.0.0";
      environment = {
        HOME = "/var/lib/open-webui";
      };
    };
  };

}
