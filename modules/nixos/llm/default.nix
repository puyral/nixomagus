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

    containerized = mkEnableOption "run ollama in docker container";

    acceleration = mkOption {
      description = "What interface to use for hardware acceleration.";
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
    assertions = [
      {
        assertion = !(cfg.containerized && cfg.acceleration != null && cfg.acceleration != "intel");
        message = "When using containerized ollama, only 'intel' acceleration is supported. Use native ollama for other GPU types.";
      }
    ];

    virtualisation.docker.enable = lib.mkIf cfg.containerized true;
    virtualisation.oci-containers.backend = lib.mkIf cfg.containerized "docker";

    services.ollama = lib.mkIf (!cfg.containerized) {
      enable = true;
      host = "0.0.0.0";
      acceleration = cfg.acceleration;
      home = cfg.data;
      openFirewall = true;
      user = "ollama";
    };

    virtualisation.oci-containers.containers.ollama = lib.mkIf cfg.containerized {
      image = "ollama/ollama:latest";
      autoStart = true;

      volumes = [
        "${cfg.data}:/root/.ollama"
      ];

      ports = [ "11434:11434" ];

      extraOptions = [
        "--network=host"
      ] ++ (lib.optionals (cfg.acceleration == "intel") [
        "--device=/dev/dri:/dev/dri"
      ]);
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
