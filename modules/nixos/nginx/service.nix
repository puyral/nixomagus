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
      isHosting = hostName == first.hostedBy;
      chainingPort = if cfg.chainingPort != null then cfg.chainingPort else 8080;

      # Collect all provider IPs that are not the current host
      allProviders = unique (concatMap (attrs: attrs.providers) instances);
      otherProviders = filter (p: p != hostName) allProviders;
      proxyIps = map (p: config.ips.${p} or null) otherProviders;
      validProxyIps = filter (ip: ip != null) proxyIps;

      hostingConfig = optionalString (isHosting && cfg.chainingPort != null) ''
        listen ${toString chainingPort};
        ${concatMapStrings (ip: "set_real_ip_from ${ip};\n") validProxyIps}
        ${optionalString (validProxyIps != [ ]) ''
          real_ip_header X-Forwarded-For;
          real_ip_recursive on;
        ''}
      '';
    in
    {
      "${serverName}" = {
        forceSSL = first.forceHttps;
        quic = true;
        useACMEHost = config.extra.acme.domain;
        # prefer http3
        extraConfig = ''
          add_header Alt-Svc 'h3=":443"; ma=86400';
          ${hostingConfig}
        '';
        locations = lib.listToAttrs (
          map (attrs: {
            name = attrs.path;
            value = {
              proxyPass =
                let
                  targetHost =
                    if isHosting then
                      (
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
                          "localhost"
                      )
                    else
                      # We are a proxy to the host
                      (config.ips.${attrs.hostedBy} or "localhost");

                  targetPort = if isHosting then attrs.port else chainingPort;
                in
                "http://${targetHost}:${toString targetPort}";
              proxyWebsockets = true;
              extraConfig = ''
                ${optionalString (!isHosting) ''
                  proxy_set_header Connection "";
                ''}
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
      '';
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ]
    ++ (optional (cfg.chainingPort != null) cfg.chainingPort);
    networking.firewall.allowedUDPPorts = [ 443 ];

    # Ensure nginx user can access acme certs
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
