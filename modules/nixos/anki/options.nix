{ lib, config, ... }:
{
  options.extra.anki = with lib; {
    enable = mkEnableOption "anki";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/anki";
    };
    subdomain = mkOption {
      type = types.str;
      default = "anki";
    };
    port = mkOption {
      type = types.port;
      default = 27701;
    };
    users = mkOption {
      type = types.listOf types.str;
    };
    passwords = mkOption {
      type = types.pathInStore;
      default = ./passwords.sops-secret.json;
    };
    sopsKey = mkOption {
      type = types.externalPath;
      default = "/etc/ssh/ssh_host_ed25519_key";
    };
  };
}
