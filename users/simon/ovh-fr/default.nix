{ ... }:
{
  services.gpg-agent.enable = true;
  extra.llm-clients = {
      enable = true;
      lean.enable = false;
      mcp-nix.enable = false;
    };
}
