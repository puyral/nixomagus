{lib, config, pkgs-self, ...}:
let cfg = config.extra.gemini;
in
{
  options.extra.gemini = {
    enable = lib.mkEnableOption "gemini";
    lean = lib.mkEnableOption "lean mcp";
  };
  config = lib.mkIf cfg.enable {
    programs.gemini-cli = {
      enable = true;
      settings = {
        mcp = {
          allowed = ["lean"];
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