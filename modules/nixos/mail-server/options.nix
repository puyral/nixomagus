{ lib, ... }:
{
  options.extra.mail-server = with lib; {
    enable = mkEnableOption "mail-server";
    domain = mkOption {
      type = types.str;
      default = "puyral.fr";
      description = "the domain for the email addresses";
    };

    proxyProtocol = mkOption {
      type = types.bool;
      default = false;
      description = "Enable HAProxy PROXY protocol support";
    };

    relayHost = mkOption {
      type = types.nullOr (
        types.submodule (
          { ... }:
          {
            options = {
              addr = mkOption {
                type = types.str;
              };
              port = mkOption {
                type = types.port;
                default = 2525;
              };
            };
          }
        )
      );
      default = null;
      description = "Relay host for outgoing mail";
    };
  };
}
