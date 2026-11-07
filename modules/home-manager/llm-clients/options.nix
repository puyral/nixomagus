{ lib, ... }:
let

  mkEnables = names: with lib; genAttrs names (n: mkEnableOption n // { default = true; });
in
{
  options.extra.llm-clients = with lib; {
    enable = mkEnableOption "llm-clients";
    mcp = mkEnables [
      "lean"
      "mcp-nix"
      "lspranto"
    ];
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
  };
}
