{
  lib,
  config,
  pkgs-unstable,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.llm-clients;
  env = {
    LEAN_MCP = lib.mkIf cfg.mcp.lean "${pkgs-self.lean-lsp-mcp}";
    NIX_MCP = lib.mkIf cfg.mcp.mcp-nix "${pkgs-unstable.mcp-nixos}";
    LSPRANTO_MCP = lib.mkIf cfg.mcp.lspranto "${pkgs-self.lspranto}";
  };
  enabled = cfg.enable && lib.any (n: n) (lib.attrValues cfg.mcp);
in
{
  config = lib.mkIf enabled {
    programs.mcp.servers = {
      lean-mcp = {
        enable = cfg.mcp.lean;
        command = "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp";
      };
      mcp-nix = {
        enable = cfg.mcp.mcp-nix;
        command = "${pkgs-unstable.mcp-nixos}/bin/mcp-nixos";
      };
    };

    home.sessionVariables = env;
    systemd.user.sessionVariables = env;
  };
}
