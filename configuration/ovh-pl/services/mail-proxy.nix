{ config, lib, ... }:
let
  dynasIp = config.ips.dynas;
in
{
  # 1. Postfix Relay for Outbound (Dynas -> OVH -> World)
  # services.postfix = {
  #   enable = true;
  #   # networks = [
  #   #   # "127.0.0.0/8"
  #   #   "100.64.0.0/10"
  #   # ]; # Trust Tailscale
  #   config = {
  #   inet_interfaces = config.ips.ovh-pl; # REPLACE with VPS Tailscale IP
  #   mynetworks = [config.extra.tailscale.prefix.v4 config.extra.tailscale.prefix.v6]; # Trust Tailscale network
  #   relay_domains = []; 
  #   # Standard outgoing setup
  # };
  #   # config = {
  #   #   smtpd_relay_restrictions = "permit_mynetworks, reject";
  #   #   inet_interfaces = "127.0.0.1";
  #   # };
  #   # Listen on Tailscale IP:2525 for relay
  #   masterConfig = {
  #     "${config.ips.ovh-pl}:2525" = {
  #       type = "inet";
  #       private = false;
  #       command = "smtpd";
  #     };
  #   };
  # };

  networking.firewall.allowedTCPPorts = [
    2525
    25
    587
    465
    993
  ];

  # 2. Traefik Proxy for Inbound (World -> OVH -> Dynas)
  services.traefik.dynamicConfigOptions.tcp = {
    routers = {
      smtp = {
        rule = "HostSNI(`*`)";
        entryPoints = [ "smtp" ];
        service = "smtp-backend";
      };
      submission = {
        rule = "HostSNI(`*`)";
        entryPoints = [ "submission" ];
        service = "submission-backend";
      };
      smtps = {
        rule = "HostSNI(`*`)";
        entryPoints = [ "smtps" ];
        service = "smtps-backend";
      };
      imaps = {
        rule = "HostSNI(`*`)";
        entryPoints = [ "imaps" ];
        service = "imaps-backend";
      };
    };
    services = {
      smtp-backend.loadBalancer = {
        servers = [ { address = "${dynasIp}:25"; } ];
        proxyProtocol.version = 2;
      };
      submission-backend.loadBalancer = {
        servers = [ { address = "${dynasIp}:587"; } ];
        proxyProtocol.version = 2;
      };
      smtps-backend.loadBalancer = {
        servers = [ { address = "${dynasIp}:465"; } ];
        proxyProtocol.version = 2;
      };
      imaps-backend.loadBalancer = {
        servers = [ { address = "${dynasIp}:993"; } ];
        proxyProtocol.version = 2;
      };
    };
  };

  services.traefik.staticConfigOptions.entryPoints = {
    smtp.address = ":25";
    submission.address = ":587";
    smtps.address = ":465";
    imaps.address = ":993";
  };
}
