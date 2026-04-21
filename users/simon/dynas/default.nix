{ pkgs, pkgs-self, ... }:
{
  services.gpg-agent.enable = true;
  extra = {
    llm-clients = {
      enable = true;
      lean.enable = false;
    };
  };

  home.packages = (
    with pkgs;
    [
      nvtopPackages.intel
    ]
  );
}
