{ pkgs, pkgs-self, ... }:
{
  services.gpg-agent.enable = true;
  extra = {
    opencode.enable = true;
  };

  home.packages = (
    with pkgs;
    [
      nvtopPackages.intel
      # pkgs-self.sandbox
    ]
  );
}
