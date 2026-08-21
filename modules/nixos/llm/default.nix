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

  audio-cpp-server = if llama-swap-cfg.audioCppPackage != null then
    lib.getExe' llama-swap-cfg.audioCppPackage "audiocpp_server"
  else
    throw "extra.llm.llama-swap: audioCppPackage must be set to add audio-cpp models";

  # Audio.cpp server.json generated per audio-cpp model. All unconditionally-set
  # fields are required by load_server_config (id/path/family).
  buildAudioServerJson =
    model:
    let
      modelEntry = {
        id = model.id;
        path = model.model;
        family = model.family;
        task = model.task;
        mode = model.mode;
      } // lib.optionalAttrs (model.audioDefaultRequestOptions != { }) {
        default_request_options = model.audioDefaultRequestOptions;
      } // lib.optionalAttrs (model.audioDefaultVoicePreset != { }) {
        default_voice_preset = model.audioDefaultVoicePreset;
      };
    in
    pkgs.writeText "audiocpp-${model.id}.json" (builtins.toJSON {
      host = "127.0.0.1";
      lazy_load = true;
      models = [
        modelEntry
      ];
    });

  buildModelConfig =
    model:
    let
      gpuLayers = lib.optionalString (model.nGpuLayers != null) "-ngl ${toString model.nGpuLayers}";
      contextArg = lib.optionalString (model.contextSize != null) "-c ${toString model.contextSize}";
      parallelArg = lib.optionalString (
        model.parallelSequences != null
      ) "-np ${toString model.parallelSequences}";
      extraArgsStr = lib.concatStringsSep " " model.extraArgs;
    in
    if model.kind == "audio-cpp" then
      let
        backend = if (model.backend != null) then model.backend else (if cfg.acceleration == null then "cpu" else cfg.acceleration);
        serverJson = buildAudioServerJson model;
      in
      {
        inherit (model) env;
        cmd = "${audio-cpp-server} --config ${serverJson} --port \${PORT} --backend ${backend} --no-ui";
        aliases = model.aliases;
        concurrencyLimit = model.concurrencyLimit;
        ttl = if (model.ttl == null) then llama-swap-cfg.ttl else model.ttl;
      }
    else
      {
        inherit (model) env;
        cmd = "${llama-server} --port \${PORT} -m ${model.model} ${gpuLayers} ${contextArg} ${parallelArg} ${extraArgsStr} --no-webui";
        aliases = model.aliases;
        concurrencyLimit = model.concurrencyLimit;
        ttl = if (model.ttl == null) then llama-swap-cfg.ttl else model.ttl;
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
      openFirewall = true;
    };

    systemd.services.llama-swap.serviceConfig = lib.mkIf llama-swap-cfg.enable {
      ProcSubset = lib.mkForce "all";
    };
  };

}
