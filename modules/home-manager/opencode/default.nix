{ lib, config, ... }:

with lib;
let
  cfg = config.extra.opencode;
in
{
  options.extra.opencode.enable = mkEnableOption "opencode";

  config = mkIf cfg.enable {

    programs.opencode = {
      enable = true;
      settings = {
        permission = {
          "*" = "ask";
          bash = {
            "nix build*" = "allow";
            "cargo check*" = "allow";
            "cargo build*" = "allow";
            "lake build*" = "allow";
            "ls*" = "allow";
            "grep*" = "allow";
            "head*" = "allow";
            "tail*" = "allow";
          };
        };
        share = "disabled";
        disabled_providers = [
          "opencode"
          "zen"
        ];
        provider = {
          aqueduct = {
            npm = "@ai-sdk/openai-compatible";
            name = "aqueduct.ai.datalab.tuwien.ac.at";
            options = {
              baseURL = "https://aqueduct.ai.datalab.tuwien.ac.at/";
              apiKey = builtins.readFile ./secrets/api-key;
            };
            models = {
              "glm-4.7-355b" = {
                name = "glm-4.7-355b";
                options = {
                  temperature = 0.2;
                };
                limit = {
                  context = 160000;
                  output = 160000;
                };
              };
            };
          };
        };
      };

    };

  };
}
