{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.extra.silverbullet;
  name = "silverbullet";
  spaceDir = "/space";
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    containers.${name} = {
      bindMounts."${spaceDir}" = {
        hostPath = cfg.dataDir;
        isReadOnly = false;
      };
      autoStart = true;
      ephemeral = true;

      config =
        { config, pkgs, ... }:
        {
          services.silverbullet = {
            enable = true;
            package = pkgs-unstable.silverbullet;
            openFirewall = true;
            listenAddress = "0.0.0.0";
            listenPort = cfg.port;
            spaceDir = spaceDir;
          };

          systemd.services.silverbullet.serviceConfig.ExecStartPre = [
            "+${pkgs.coreutils}/bin/chown ${config.services.silverbullet.user}:${config.services.silverbullet.group} ${spaceDir}"
          ];
        };
    };

    extra.containers.${name} = {
      nginx = [
        {
          port = cfg.port;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.providers;
        }
      ];
    };
  };
}
