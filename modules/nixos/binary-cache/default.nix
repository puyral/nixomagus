{ config, lib, ... }:
let
  cfg = config.extra.cache;
  cname = "binary-cache";
  port = cfg.port;

in

{
  imports = [
    ./options.nix
    ./substituter.nix
  ];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.substituter;
        message = "you can be substituter on your own machine";
      }
    ];
    containers.${cname} = {
      autoStart = true;
      ephemeral = true;
      config =
        { ... }:
        {
          services.nix-serve = {
            inherit port;
            enable = true;
            secretKeyFile = "${./secrets/cache-priv-key.pem}";
            openFirewall = true;
          };
        };
    };

    extra.containers.${cname} = {
      traefik = [
        {
          inherit port;
          enable = true;
          name = "nix.dynas";
        }
      ];
    };
  };
}
