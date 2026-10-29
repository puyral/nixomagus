{ lib, computer, ... }: {
  options.extra.pi-ops-redirect = with lib; {
    enable = mkEnableOption "redirect to pi-ops";
    subdomain = mkOption {
      description = "pi.<subdomain>.puyral.fr";
      type = types.str;
      default = "${computer.name}";
    };
    extraProviders = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    resolver = mkOption {
      type = types.str;
      description = "the unicast DNS resolver nginx uses to resolve the backend";
      default = "127.0.0.53";
    };
    backend = mkOption {
      type = types.str;
      description = "the hostname of the pi-ops backend, resolvable by `resolver`";
      default = "sandbox.local";
    };
  };
}
