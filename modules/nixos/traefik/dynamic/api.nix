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
        "test:$2y$05$GjUz6dUGeO.phxViAdgrD.tfuHkwCrhKvCLxMQLPjyPpGcjNVvtdq"
      ];
    };
  };
}
