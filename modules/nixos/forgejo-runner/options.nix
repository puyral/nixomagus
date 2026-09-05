{
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.extra.forgejo-runners = {
    enable = mkEnableOption "forgejo-runner";
    package = mkPackageOption pkgs "forgejo-runner" { };
    sopsKey = mkOption {
      type = types.externalPath;
      default = "/etc/ssh/ssh_host_ed25519_key";
      description = "Host SSH key bound into the container and used by sops-nix to decrypt secrets.";
    };
    runners = mkOption {
      type = with types; attrsOf (submodule (
        { ... }:
        {
          options = {
            enable = mkEnableOption "this runner";
            url = mkOption {
              type = types.str;
              description = "Base URL of the Forgejo instance to connect to.";
            };
            tokenFile = mkOption {
              type = types.path;
              description = "Sops-encrypted dotenv file containing the runner token as `TOKEN=...`.";
            };
            labels = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Labels used to map jobs to their runtime environment.";
            };
            hostPackages = mkOption {
              type = types.listOf types.package;
              default = [ ];
              description = "Packages available to workflows when using a `host` label.";
            };
            settings = mkOption {
              type = types.attrs;
              default = { };
              description = "Extra free-form settings merged into the runner config.";
            };
          };
        }
      ));
      default = { };
    };
  };
}
