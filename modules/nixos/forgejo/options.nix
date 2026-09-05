{ lib, config, ... }:
with lib;
{
  options.extra.forgejo = {
    enable = mkEnableOption "forgejo";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/forgejo";
    };
    subdomain = mkOption {
      type = types.str;
    };
    providers = mkOption {
      type = with types; listOf str;
      example = [ "ovh-pl" ];
    };
    sshPort = mkOption {
      type = types.port;
      default = 222;
      description = "External SSH port shown in clone URLs and forwarded from the host.";
    };
    sshListenPort = mkOption {
      type = types.port;
      default = 2222;
      description = ''
        Port forgejo's built-in SSH server actually listens on inside the
        container. Must be a high port (>1024) because the hardened forgejo
        service has no CAP_NET_BIND_SERVICE, so it cannot bind privileged
        ports. The host forwards sshPort to this port.
      '';
    };
  };
}
