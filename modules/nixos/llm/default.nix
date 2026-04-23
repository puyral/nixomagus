{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

let
  cfg = config.extra.llm;
  llama-swap-cfg = cfg.llama-swap;

  llama-server = lib.getExe' llama-swap-cfg.llamaCppPackage "llama-server";

  buildModelConfig = model:
    let
      gpuLayers = if model.nGpuLayers == -1 then "999" else toString model.nGpuLayers;
      contextArg = lib.optionalString (model.contextSize != null) "-c ${toString model.contextSize}";
      parallelArg = lib.optionalString (model.parallelSequences != null) "-np ${toString model.parallelSequences}";
      extraArgsStr = lib.concatStringsSep " " model.extraArgs;
    in
    {
      cmd = "${llama-server} --port ${"$"}{PORT} -m ${model.model} -ngl ${gpuLayers} ${contextArg} ${parallelArg} ${extraArgsStr} --no-webui";
      aliases = model.aliases;
      concurrencyLimit = model.concurrencyLimit;
    };

  modelsAttrs = lib.listToAttrs (
    map (model: {
      name = model.id;
      value = buildModelConfig model;
    }) llama-swap-cfg.models
  );
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = cfg.ollama.enable;
      host = cfg.ollama.host;
      port = cfg.ollama.port;
      acceleration = cfg.acceleration;
      home = cfg.ollama.data;
      openFirewall = true;
      user = "ollama";
    };

    services.open-webui = {
      enable = cfg.open-webui.enable;
      port = cfg.open-webui.port;
      openFirewall = true;
      host = cfg.open-webui.host;
      environment = {
        HOME = cfg.open-webui.data;
      };
    };

    services.llama-swap = lib.mkIf llama-swap-cfg.enable {
      enable = true;
      package = pkgs.llama-swap;
      port = llama-swap-cfg.port;
      settings = {
        healthCheckTimeout = llama-swap-cfg.healthCheckTimeout;
        models = modelsAttrs;
      };
    };
  };

}
