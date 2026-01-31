{ config, lib, ... }:
let
  cfg = config.extra.mail-server;
  domain = cfg.domain;
in
{

  config = lib.mkIf cfg.enable {
    services.postfix.config = lib.mkMerge [
      (lib.mkIf (cfg.relayHost != null) {
        relayhost = [ "[${cfg.relayHost.addr}]:${builtins.toString cfg.relayHost.port}" ];
      })
      (lib.mkIf cfg.proxyProtocol {
        postscreen_upstream_proxy_protocol = "haproxy";
        smtpd_upstream_proxy_protocol = "haproxy";
      })
    ];
    services.dovecot2 = lib.mkIf cfg.proxyProtocol {
      extraConfig =
        ''
          haproxy_trusted_networks = ${config.extra.tailscale.prefix.v4} ${config.extra.tailscale.prefix.v6}
          service imap-login {
            inet_listener imap {
              haproxy = yes
            }
            inet_listener imaps {
              haproxy = yes
            }
          }
        '';
    };
  };
}
