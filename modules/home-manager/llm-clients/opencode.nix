{
  lib,
  config,
  ...
}:
let
  cfg = config.extra.llm-clients;
  mkAllows = patts: lib.genAttrs patts (_: "allow");
  jailed = config.extra.jail.enable;
  apiKeyPath = n: config.sops.secrets."llm/${n}".path;
  mkApiKey = n: "{file:${apiKeyPath n}}";

  mkReasoningEffort = effort: {
    chat_template_kwargs = {
      thinking = true;
      reasoning_effort = effort;
    };
  };
  mkVariants = v: lib.genAttrs v mkReasoningEffort;

  withVision = {
    input = [
      "text"
      "image"
    ];
    output = [ "text" ];
  };

  defaultTU = {
    interleaved.field = "reasoning_content";
    options = mkReasoningEffort "high";
    variants = mkVariants [
      "high"
      "max"
    ];
  };

  mkOpenAiCompatible = name: url: key: {
    inherit name;
    npm = "@ai-sdk/openai-compatible";
    options = {
      baseURL = url;
      apiKey = mkApiKey key;
    };
  };
in

{
  # TODO: when to times come, update to v2
  config = lib.mkIf (cfg.enable && cfg.opencode.enable) {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      skills = ./skills;
      settings = {
        permission =
          (mkAllows [
            "read"
            "glob"
            "explore"
            "grep"
            "task"
            "websearch"
            "webfetch"
            "codesearch"
            "todowrite"
            "question"
            "skills"
          ])
          // {
            "*" = if jailed then "allow" else "ask";
            bash = mkAllows [
              "rg*"
              "nix*"
              "cargo check*"
              "cargo build*"
              "lake build*"
              "ls*"
              "grep*"
              "head*"
              "tail*"
              "jq*"
              "find*"
              "cat*"
              "wc*"
              "git status*"
              "git diff*"
              "git show*"
              "git log*"
              "rebuild --dry-run --no-sign"
              "ls*"
              "hostname"
            ];
          };
        share = "disabled";
        disabled_providers = [
          "opencode"
          "zen"
        ];
        provider = {
          openrouter = mkOpenAiCompatible "OpenRouter" "https://openrouter.ai/api/v1" "OPENROUTER";
          aqueduct = (mkOpenAiCompatible "TU Wien" "https://aqueduct.ai.datalab.tuwien.ac.at/" "TU-WIEN") // {
            models = {
              "glm-5.3-744b-experimental" = defaultTU // {
                name = "GLM 5.3";
              };
              "vision" = {
                name = "Qwen 3.8 27B";
                modalities = withVision;
              };
              "main" = defaultTU // {
                name = "DeepSeek V4 Vision Flash";
                modalities = withVision;
              };
            };
          };
        };
      };
    };
  };
}
