{
  lib,
  config,
  ...
}:
let
  cfg = config.extra.llm-clients;
  mkSopsOne = name: {
    sopsFile = ./credentials.sops-secret.json;
    format = "json";
    key = name;
  };
  mkSops = names: with lib; genAttrs' names (n: nameValuePair "llm/${n}" (mkSopsOne n));
in
{
  imports = [
    ./options.nix
    ./gemini.nix
    ./mcp.nix
    ./opencode.nix
  ];

  config = lib.mkIf cfg.enable {
    sops.secrets = mkSops [
      "TU-WIEN"
      "MISTRAL"
      "OPENROUTER"
      "STRATA"
    ];
  };
}
