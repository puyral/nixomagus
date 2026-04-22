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
  nixMcp = cfg.mcp-nix.enable;

  jailed = config.extra.jail.enable;
in
{
  options.extra.llm-clients = with lib; {
    enable = mkEnableOption "llm-clients";
    lean = {
      enable = mkEnableOption "lean";
      mcp = mkEnableOption "lean mcp server" // {
        default = true;
      };
      lsp = lib.mkEnableOption "lean lsp server";
    };
    mcp-nix = {
      enable = mkEnableOption "mcp-nix" // {
        default = true;
      };
    };

    opencode = {
      enable = mkEnableOption "opencode" // {
        default = true;
      };
    };

    gemini = {
      enable = mkEnableOption "gemini" // {
        default = true;
      };
    };

    mistral-vibe = {
      enable = mkEnableOption "mistral-vibe" // {
        default = true;
      };
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
            mcp-nix = "allow";
          };
        share = "disabled";
        disabled_providers = [
          "opencode"
          "zen"
        ];
        installed_agents = [ "nix-helper" ] ++ lib.optional leanEnableMcp "lean";
        skill_paths = [
          "~/.gemini/skills"
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
          // (lib.optionalAttrs leanEnableMcp {
            lean-mcp = {
              type = "local";
              command = [ "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp" ];
            };
          })
          // (lib.optionalAttrs nixMcp {
            mcp-nix = {
              type = "local";
              command = [ "${pkgs-unstable.mcp-nixos}/bin/mcp-nixos" ];
            };
          });
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
          previewFeatures = true;
        };
        model = {
          name = "auto-gemini-3";
        };
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
          disableYoloMode = !jailed;
        };
        context = {
          fileFiltering = {
            respectGitIgnore = false;
          };
        };
        mcp = {
          allowed = lib.optionals leanEnableMcp [ "lean" ] ++ lib.optionals nixMcp [ "nix" ];
        };
        mcpServers = {
          lean = lib.mkIf leanEnableMcp {
            command = "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp";
            trust = true;
          };
          nix = lib.mkIf nixMcp {
            command = "${pkgs-unstable.mcp-nixos}/bin/mcp-nixos";
            trust = true;
          };
        };
      };
    };

    home.file.".gemini/skills/nix-helper/SKILL.md" = lib.mkIf cfg.gemini.enable {
      source = ./skills/nix-helper/SKILL.md;
    };

    home.file.".gemini/policies/mcp-nixos.toml" = lib.mkIf (cfg.gemini.enable && nixMcp) {
      text = ''
        [[rule]]
        mcpName = "nix"
        decision = "allow"
        priority = 100
      '';
    };

    home.sessionVariables = lib.mkIf cfg.mistral-vibe.enable {
      MISTRAL_API_KEY = builtins.readFile ./secrets/mistral-api-key;
      # MISTRAL_TRUST_ALL_TOOLS = lib.mkIf (
      #   jailed
      # ) "1";
    };

    home.file.".vibe/config.toml" = lib.mkIf (cfg.mistral-vibe.enable && leanEnableMcp) {
      text =
        (lib.optionalString jailed ''
          auto_approve = true
        '')
        # + ''

        #   [[providers]]
        #   name = "mistral"
        #   api_base = "https://api.mistral.ai/v1"
        #   api_key_env_var = "${builtins.readFile ./secrets/mistral-api-key}"
        #   api_style = "openai"
        #   backend = "mistral"
        #   reasoning_field_name = "reasoning_content"
        #   project_id = ""
        #   region = ""
        # ''
        + (lib.optionalString (cfg.mistral-vibe.enable) ''

          installed_agents = [
              "nix-helper",
          ]

          [[mcp_servers]]
          name = "mcp-nixos"
          transport = "stdio"
          command = "${pkgs-unstable.mcp-nixos}/bin/mcp-nixos"

          [[skill_paths]]
          path = "~/.gemini/skills"
        '')
        + (lib.optionalString leanEnableMcp ''

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
        '');
    };

  };
}
