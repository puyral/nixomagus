{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
{
  networking.nginx.instances."openwebui"= {
    enable = true;
    port = 8081;
    providers = ["dynas" "ovh-pl"];
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
        llamaCppPackage = pkgs-unstable.llama-cpp-vulkan;
        ttl = 300;
        models = [
          {
            id = "ministral";
            model = "/mnt/Zeno/containers/llm/llama-cpp/models/Ministral-3-8B-Instruct-2512-UD-Q6_K_XL.gguf";
          }
          {
            id = "ministral-2K";
            aliases = [ "mini-ministral" ];
            model = "/mnt/Zeno/containers/llm/llama-cpp/models/Ministral-3-8B-Instruct-2512-UD-Q6_K_XL.gguf";
            contextSize = 2048;
          }
          {
            id = "qwen-9B";
            model = "/mnt/Zeno/containers/llm/llama-cpp/models/Qwen3.5-9B-UD-Q6_K_XL.gguf";
            extraArgs = [
              "--top-p 0.95"
              "--top-k 20"
              "--min-p 0.00"
              "--chat-template-kwargs '{\"enable_thinking\":true}'"
            ];
          }
          {
            id = "qwen-9B-long";
            model = "/mnt/Zeno/containers/llm/llama-cpp/models/Qwen3.5-9B-UD-Q4_K_XL.gguf";
            contextSize = 100 * 1024;
            extraArgs = [
              "--top-p 0.95"
              "--top-k 20"
              "--min-p 0.00"
              "--chat-template-kwargs '{\"enable_thinking\":true}'"
            ];
          }
          {
            id = "qwen-9B-32K";
            model = "/mnt/Zeno/containers/llm/llama-cpp/models/Qwen3.5-9B-UD-Q6_K_XL.gguf";
            contextSize = 32 * 1024;
            extraArgs = [
              "--top-p 0.95"
              "--top-k 20"
              "--min-p 0.00"
            ];
          }
          {
            id = "qwen-0.8B-2K";
            model = "/mnt/Zeno/containers/llm/llama-cpp/models/Qwen3.5-9B-UD-Q4_K_XL.gguf";
            extraArgs = [
              "--top-p 0.95"
              "--top-k 20"
              "--min-p 0.00"
              "--chat-template-kwargs '{\"enable_thinking\":false}'"
              "--temperature 0.4"
            ];
            contextSize = 3 * 1024;
          }
        ];
      };
    };

    n8n.enable = true;
  };
}
