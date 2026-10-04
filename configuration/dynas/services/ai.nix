{
  pkgs,
  pkgs-unstable,
  pkgs-node,
  pkgs-self,
  config,
  lib,
  ...
}:
let
  modelsDir = "/mnt/Zeno/containers/llm-models";
in
{
  networking.nginx.instances."openwebui" = {
    enable = true;
    port = 8081;
    providers = [
      "dynas"
      config.vars.gatewayMachine
    ];
  };

  extra = {
    llm = {
      enable = true;
      acceleration = "vulkan";
      data = "${config.params.locations.containers}/llm";
      defaultLLM = "ministral-3:14b";
      open-webui.data = "/var/lib/open-webui"; # <- todo: migrate

      llama-swap = {
        enable = true;
        llamaCppPackage = pkgs-node.llama-cpp-vulkan;
        ttl = 300;
        models = [
          {
            id = "ministral";
            model = "${modelsDir}/Ministral-3-8B-Instruct-2512-UD-Q6_K_XL.gguf";
          }
          {
            id = "qwen-9B";
            model = "${modelsDir}/Qwen3.5-9B-UD-Q6_K_XL.gguf";
            extraArgs = [
              "--top-p 0.95"
              "--top-k 20"
              "--min-p 0.00"
              "--chat-template-kwargs '{\"enable_thinking\":true}'"
            ];
          }
          {
            id = "qwen-0.8B-3K";
            model = "${modelsDir}/Qwen3.5-9B-UD-Q4_K_XL.gguf";
            extraArgs = [
              "--top-p 0.95"
              "--top-k 20"
              "--min-p 0.00"
              "--chat-template-kwargs '{\"enable_thinking\":false}'"
              "--temperature 0.4"
            ];
            contextSize = 3 * 1024;
          }
          {
            id = "gemma-4-12B-it-qat-UD-Q4";
            model = "${modelsDir}/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf";
          }
          {
            # https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF
            id = "qwen 3.8 27B";
            model = "${modelsDir}/Qwen3.8-27B-GSQ-RCO-IQ2_XS.gguf";
            contextSize = 90 * 1024;
            # nGpuLayers = "all";
            extraArgs = [
              "--top-p 0.95"
              "--top-k 20"
              "--min-p 0.00"
              # "--temperature 1"
              "--presence_penalty 0.0"
              "--repeat-penalty 1.0"

              "--cache-type-k q8_0"
              "--cache-type-v q4_0"
              "-ngl all"
              "--parallel 1"

              "--mmproj ${modelsDir}/mmproj-Qwen3.8-27B-BF16.gguf"
            ];
          }
        ];
      };
    };

    n8n.enable = true;

    audioCpp = {
      enable = false;
      package = pkgs-self.audio-cpp-vulkan;
      backend = "vulkan";
      extraOptions = {
        voice_dir = "${modelsDir}/voices";
        idle_unload_ms = 10000;
        max_loaded_models = 1;
      };
      models =
        let
          base = {
            task = "tts";
            mode = "offline";
          };
          mkQwen =
            name:
            base
            // rec {
              family = "qwen3_tts";
              id = "${family}-${name}";
              model = "${modelsDir}/qwen3-tts-12hz-1.7b-${name}-bf16.gguf";
            };

          higgs = base // {
            id = "higgs-tts";
            family = "higgs_audio_tts";
            model = "${modelsDir}/higgs-audio-v3-tts-4b-bf16.gguf";
          };

          voxcpm2 = base // rec {
            family = "voxcpm2";
            id = family;
            model = "${modelsDir}/voxcpm2-orig.gguf";
          };

        in

        [
          voxcpm2
          higgs
        ]
        ++ (lib.map mkQwen [
          "base"
          "customvoice"
          "voicedesign"
        ]);
    };
  };
}
