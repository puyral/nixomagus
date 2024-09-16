{ ... }:
{
  services.traefik.dynamicConfigOptions = {
    # http:
    #   routers:
    #     dashboard:
    #       rule: Host(`traefik.example.com`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))
    #       service: api@internal
    #       middlewares:
    #         - auth
    #   middlewares:
    #     auth:
    #       basicAuth:
    #         users:
    #           - "test:$apr1$H6uskkkW$IgXLP6ewTrSuBkTrqE8wj/"
    #           - "test2:$apr1$d9hr9HBB$4HxwgUir3HP4EsggP/QNo0"

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
