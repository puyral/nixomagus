{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.networking.nginx;
  hostName = config.networking.hostName;

  activeInstances = lib.filterAttrs (
    _: { enable, providers, ... }: enable && (builtins.elem hostName providers)
  ) cfg.instances;

  # Group instances by server name (host.domain)
  groupedInstances =
    let
      mkServerName =
        name: attrs:
        let
          domain = if attrs.domain == null then cfg.baseDomain else attrs.domain;
          sub = if (attrs ? subdomain && attrs.subdomain != null) then attrs.subdomain else name;
        in
        "${sub}.${domain}";
    in
    lib.foldl' (
      acc: name:
      let
        attrs = activeInstances.${name};
        serverName = mkServerName name attrs;
      in
      acc
      // {
        "${serverName}" = (acc."${serverName}" or [ ]) ++ [ (attrs // { instanceName = name; }) ];
      }
    ) { } (builtins.attrNames activeInstances);

  mkVHost =
    serverName: instances:
    let
      # Use the first instance's settings for the server-level options
      first = builtins.head instances;
    in
    {
      "${serverName}" = {
        forceSSL = first.forceHttps;
        quic = true;
        useACMEHost = config.extra.acme.domain;
        # prefer http3
        extraConfig = ''
          add_header Alt-Svc 'h3=":443"; ma=86400';
        '';
        locations = lib.listToAttrs (
          map (attrs: {
            name = attrs.path;
            value = {
              proxyPass =
                let
                  targetHost =
                    if attrs.address != null then
                      attrs.address
                    else if (attrs ? container && attrs.container != null) then
                      let
                        containerConfig = config.containers.${attrs.container};
                      in
                      if containerConfig ? localAddress && containerConfig.localAddress != null then
                        containerConfig.localAddress
                      else
                        "localhost"
                    else
                      "localhost";
                in
                "http://${targetHost}:${toString attrs.port}";
              proxyWebsockets = true;
              extraConfig = ''
                ${attrs.extraConfig}
              '';
            };
          }) instances
        );
      };
    };

  virtualHosts = lib.foldl' (acc: name: acc // (mkVHost name groupedInstances.${name})) { } (
    builtins.attrNames groupedInstances
  );

in
{
  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      experimentalZstdSettings = true;
      recommendedGzipSettings = true;
      sslProtocols = "TLSv1.3";
      inherit virtualHosts;

      # :TLS_AES_128_GCM_SHA256
      appendHttpConfig = ''
        # see https://datatracker.ietf.org/doc/html/rfc8446#section-9.1
        ssl_conf_command Ciphersuites TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256;
        ssl_ecdh_curve X25519:secp384r1;
      '';
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [ 443 ];

    # Ensure nginx user can access acme certs
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
