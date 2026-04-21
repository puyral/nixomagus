{ lib, ... }:
{
  # Minimal home-manager config for the sandbox
  # imports = [ ./commun ]; # already imported by users/simon/default.nix
  extra = {
    jail.enable = true;

    llm-clients = {
      enable = true;
      lean.enable = true;
    };
  };
  programs.git.settings = {
    safe.directory = lib.mkForce "/mnt/host";
  };
  programs.gh.enable = lib.mkForce false;
}
