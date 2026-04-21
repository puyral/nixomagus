{ pkgs, pkgs-self, ... }:
{
  services.gpg-agent.enable = true;
  extra = {
    llm-clients = {
      enable = true;
      opencode.enable = true;
    };
  };

  home.packages = (
    with pkgs;
    [
      nvtopPackages.intel
    ]
  );
}
