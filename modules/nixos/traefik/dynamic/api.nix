{ ... }:
{
  services.traefik.dynamicConfigOptions = {
    http = {
      routers.dashboard = {
        rule = "Host(`traefik.dynas.puyral.fr`)";
        service = "api@internal";
        middlewares = [ "auth" ];
        tls.certResolver = "ovh";
      };
      middlewares.auth.basicAuth.users = [
        "admin:$2y$05$LBy0ZJiKSvCiL0cOqIZgFu0ktqkewdKN6MVIIz3WX2OXsDkHD7Q02"
      ];
    };
  };
}
