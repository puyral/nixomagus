{ ... }:
{
  config.services.traefik.dynamicConfigOptions.http = {
    middlewares = {
      redirect-to-https = {
        redirectScheme = {
          scheme = "https";
          permanent = true;
        };
      };
    };
  };
}
