{ ... }:
{
  # Minimal home-manager config for the sandbox
  # imports = [ ./commun ]; # already imported by users/simon/default.nix
  extra = {
    jail.enable = true;

    opencode = {
      enable = true;
      leanSupport.mcp = true;
    };
  };
}
