{ ... }:
{
  services.gpg-agent.enable = true;
  extra.shell.rebuildScript = ./rebuild.sh;
}
