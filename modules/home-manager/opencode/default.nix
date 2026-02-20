{
  lib,
  pkgs,
  pkgs-self,
  config,
  ...
}:

with lib;
let
  cfg = config.extra.opencode;
in
{
  options.extra.opencode = {
    enable = mkEnableOption "opencode";
    leanSupport = {
      mcp = mkEnableOption "lean mcp server";
      lsp = mkEnableOption "lean lsp server";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ jq ];

    programs.opencode = {
      enable = true;
      settings = {
        permission =
          let
            mkAllow = patt: {
              name = patt;
              value = "allow";
            };
            mkAllows = with builtins; patts: listToAttrs (map mkAllow patts);

          in
          {
            "*" = "ask";
            read = "allow";
            webfetch = "allow";
            glob = "allow";
            explore = "allow";
            grep = "allow";
            bash = mkAllows [
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
              "git status*"
              "git diff*"
              "rebuild --dry-run --no-sign"
            ];
            lean-lsp-mcp = "allow";
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
                # options = {
                #   temperature = 0.2;
                # };
                # limit = {
                #   context = 160000;
                #   output = 160000;
                # };
              };
            };
          };
        };
        mcp =
          { }
          // lib.optionalAttrs cfg.leanSupport.mcp {
            lean-mcp = {
              type = "local";
              command = [ "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp" ];
            };
          };
        lsp =
          { }
          // lib.optionnalAttrs cfg.leanSupport.lsp {
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

  };
}
