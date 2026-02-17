{ config, ... }:
let
  name = config.networking.hostName;
in
{
  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        dashboard = {
          rule = "Host(`traefik.${name}.puyral.fr`)";
          service = "api@internal";
          middlewares = [ "auth" ];
          entryPoints = [ "https" ];
          tls.certResolver = "ovh";
        };
        dashboard-insecure = {
          rule = "Host(`traefik.${name}.puyral.fr`)";
          entryPoints = [ "http" ];
          middlewares = [ "redirect-to-https" ];
          service = "api@internal";
        };
      };
      middlewares.auth.basicAuth.users = [
        "admin:$2y$05$LBy0ZJiKSvCiL0cOqIZgFu0ktqkewdKN6MVIIz3WX2OXsDkHD7Q02"
      ];
    };
  };
}
