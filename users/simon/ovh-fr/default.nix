{ ... }:
{
  services.gpg-agent.enable = true;
  extra.llm-clients = {
    enable = true;
    mcp.lean = false;
  };
}
