{
  self,
  config,
  lib,
  ...
}:
{
  imports = [ ];

  networking = {
    nat = {
      enable = true;
      externalInterface = "ens3";
    };
    traefik = {
      enable = true;
      # docker.enable = true;
      # log.level = "DEBUG";
      instances = self.nixosConfigurations.dynas.config.networking.traefik.instances;
    };
  };

  services.rustdesk-server = {
    enable = false;
    openFirewall = true;
  };
  systemd.services =
    let
      cfg = config.services.rustdesk-server;
    in
    lib.mkIf cfg.enable {
      rustdesk-signal.serviceConfig.ExecStart = lib.mkForce "${cfg.package}/bin/hbbs";
    };
  extra = {
    headscale = {
      enable = true;
      extraDomain = "headscale";
    };
    authelia = {
      enable = true;
    };
    mail-server = {
      enable = true;
      remoteStorage = {
        enable = true;
        remote = {
          ip = config.ips.dynas;
          path = "/mnt/Zeno/containers/emails";
        };
        local = {
          base = "/containers/emails";
          storage = "/containers/emails/dir";
        };
      };
    };
  };
}
