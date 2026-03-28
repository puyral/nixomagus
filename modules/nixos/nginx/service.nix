{ lib, config, ... }:
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
      mkServerName = name: attrs:
        let
          domain = if attrs.domain == null then cfg.baseDomain else attrs.domain;
        in
        "${name}.${domain}";
    in
    lib.foldl' (acc: name:
      let
        attrs = activeInstances.${name};
        serverName = mkServerName name attrs;
      in
      acc // {
        "${serverName}" = (acc."${serverName}" or []) ++ [ (attrs // { instanceName = name; }) ];
      }
    ) {} (builtins.attrNames activeInstances);

  mkVHost = serverName: instances:
    let
      # Use the first instance's settings for the server-level options
      first = builtins.head instances;
    in
    {
      "${serverName}" = {
        forceSSL = first.forceHttps;
        useACMEHost = config.extra.acme.domain;
        locations = lib.listToAttrs (map (attrs: {
          name = attrs.path;
          value = {
            proxyPass =
              let
                targetHost =
                  if attrs.address != null then
                    attrs.address
                  else if (attrs ? container && attrs.container != null) then
                    config.containers.${attrs.container}.localAddress
                  else
                    "localhost";
              in
              "http://${targetHost}:${toString attrs.port}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              ${attrs.extraConfig}
            '';
          };
        }) instances);
      };
    };

  virtualHosts = lib.foldl' (acc: name: acc // (mkVHost name groupedInstances.${name})) {} (builtins.attrNames groupedInstances);

in
{
  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      inherit virtualHosts;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # Ensure nginx user can access acme certs
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
