{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.extra.llm-clients;
in
{
  config = lib.mkIf (cfg.enable && cfg.gemini.enable) {
    programs.antigravity-cli = lib.mkIf cfg.gemini.enable {
      enable = true;
      package = pkgs-unstable.antigravity-cli;
      enableMcpIntegration = true;
      skills = ./skills;
    };
  };
}
