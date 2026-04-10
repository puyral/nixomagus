{
  lib,
  config,
  pkgs-self,
  pkgs-unstable,
  ...
}:
let
  cfg = config.extra.gemini;
in
{
  options.extra.gemini = {
    enable = lib.mkEnableOption "gemini";
    lean = lib.mkEnableOption "lean mcp";
  };
  config = lib.mkIf cfg.enable {
    programs.gemini-cli = {
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
          allowed = [ "lean" ];
        };
        mcpServers = {
          lean = {
            command = "${pkgs-self.lean-lsp-mcp}/bin/lean-lsp-mcp";
            trust = true;
          };
        };
      };
    };
  };
}
