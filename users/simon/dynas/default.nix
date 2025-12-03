{ pkgs, ... }:
{
  services.gpg-agent.enable = true;
  # extra.shell.rebuildScript = ./rebuild.sh;

  home.packages =
    (with pkgs; [
      nvtopPackages.intel
    ]);
}
