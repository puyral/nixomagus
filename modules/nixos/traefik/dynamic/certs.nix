{ config, lib, ... }:
{
  config.services.traefik.dynamicConfigOptions.tls = lib.mkIf config.extra.acme.enable {
    certificates =
      with builtins;
      map (
        { directory, ... }:
        {
          certFile = "${directory}/cert.pem";
          keyFile = "${directory}/key.pem";
        }
      ) (attrValues config.security.acme.certs);
  };
}
