{
  lib,
  config,
  pkgs-unstable,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.llm-clients;
  mkAllow = patt: {
    name = patt;
    value = "allow";
  };
  mkAllows = with builtins; patts: lib.listToAttrs (map mkAllow patts);

  leanEnableMcp = cfg.lean.enable && cfg.lean.mcp;
  leanEnableLsp = cfg.lean.enable && cfg.lean.lsp;

  jailed = config.extra.jail.enable;
in
{
  options.extra.llm-clients = {
    enable = lib.mkEnableOption "llm-clients";
    lean = {
      enable = lib.mkEnableOption "lean";
      mcp = lib.mkEnableOption "lean mcp server" // {
        default = true;
      };
      lsp = lib.mkEnableOption "lean lsp server";
    };

    opencode = {
      enable = lib.mkEnableOption "opencode" // {
        default = true;
      };
      # aqueductApiKey = lib.mkOption {
      #   type = lib.types.str;
      #   default = "";
      #   description = "Aqueduct API key";
      # };
      # mistralApiKey = lib.mkOption {
      #   type = lib.types.str;
      #   default = "";
      #   description = "Mistral API key";
      # };
    };

    gemini = {
      enable = lib.mkEnableOption "gemini" // {
        default = true;
      };
    };

    mistral-vibe = {
      enable = lib.mkEnableOption "mistral-vibe" // {
        default = true;
      };
      # apiKey = lib.mkOption {
      #   type = lib.types.str;
      #   default = "";
      #   description = "Mistral API key for mistral-vibe";
      # };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional cfg.mistral-vibe.enable pkgs-unstable.mistral-vibe; # the othe have home manager modules already

    programs.opencode = lib.mkIf cfg.opencode.enable {
      enable = true;
      settings = {
        permission =
          let
            auto = if jailed then "allow" else "ask";
          in
          {
            "*" = auto;
            read = "allow";
            webfetch = "allow";
            glob = "allow";
            explore = "allow";
            grep = "allow";
            bash = mkAllows [
              "rg*"
              "nix build*"
              "nix search*"
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
            ];
            lean-lsp-mcp = if leanEnableMcp then "allow" else auto;
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
              apiKey = builtins.readFile ./secrets/aqueduct-api-key;
            };
            models = {
              "qwen-3.5-397b" = {
                name = "qwen-3.5-397b";
              };
            };
          };
          mistral = {
            npm = "@ai-sdk/openai-compatible";
            name = "mistral.ai";
            options = {
              baseURL = "https://api.mistral.ai/";
              apiKey = builtins.readFile ./secrets/mistral-api-key;
            };
            models = {
              "labs-leanstral-2603" = {
                name = "labs-leanstral-2603";
              };
            };
          };
        };
        mcp =
          { }
          // lib.optionalAttrs leanEnableMcp {
            lean-mcp = {
              type = "local";
              command = [ "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp" ];
            };
          };
        lsp =
          { }
          // lib.optionalAttrs leanEnableLsp {
            lean = {
              command = [
                "lake"
                "serve"
              ];
              extensions = [ ".lean" ];
            };
          };
      };
    };

    programs.gemini-cli = lib.mkIf cfg.gemini.enable {
      enable = true;
      package = pkgs-unstable.gemini-cli;
      settings = {
        general = {
          preview = true;
        };
        model = {
          name = "auto-gemini-3";
        };
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
        };
        mcp = {
          allowed = lib.optionals leanEnableMcp [ "lean" ];
        };
        mcpServers = {
          lean = lib.mkIf leanEnableMcp {
            command = "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp";
            trust = true;
          };
        };
      };
    };

    home.sessionVariables = lib.mkIf cfg.mistral-vibe.enable {
      MISTRAL_API_KEY = builtins.readFile ./secrets/mistral-api-key;
      # MISTRAL_TRUST_ALL_TOOLS = lib.mkIf (
      #   jailed
      # ) "1";
    };

    home.file.".vibe/config.toml" = lib.mkIf (cfg.mistral-vibe.enable && leanEnableMcp) {
      text = ''
        installed_agents = [
            "lean",
        ]

        [[mcp_servers]]
        name = "lean-lsp-mcp"
        transport = "stdio"
        command = "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp"
        args = [
            "--transport",
            "stdio",
        ]
      '';
    };
  };
}
