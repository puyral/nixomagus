# Lean documentation servers, hosted on `vampire` (tailscale ip 100.64.0.16),
# exposed under the `docs.puyral.fr` subdomain via path-based routing.
# Protected by HTTP basic auth (htpasswd stored in sops).
{ config, lib, ... }:
let
  htpasswd = config.sops.secrets."lean-docs-htpasswd".path;
  authConfig = ''
    auth_basic "Lean documentation";
    auth_basic_user_file ${htpasswd};
  '';
  projects = [
    "leandy"
    "herbrand"
    "leangc"
  ];
  mkInstance =
    with lib;
    i: name:
    nameValuePair "lean-${name}" {
      enable = true;
      subdomain = "docs";
      path = "/lean/${name}";
      proxyPass = "http://100.64.0.16:${toString (8080 + i)}/";
      providers = [ "ovh-fr" ];
      extraConfig = authConfig;
    };
in
{
  sops.secrets."lean-docs-htpasswd" = {
    sopsFile = ./services.sops-secret.json;
    format = "json";
    key = "lean-docs";
    owner = "nginx";
  };

  networking.nginx.instances = with lib; listToAttrs (imap0 mkInstance projects);
}
