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
    authelia.enable = true;
    bitwarden.enable = true;
    mount-containers.enable = true;
    mail-server = {
      enable = true;
      sopsKey = "/etc/ssh/ssh_host_ed25519_key";
      remoteStorage = {
        enable = true;
        local = "${config.extra.mount-containers.localPath}/mail-server/mails";
      };
    };
  };
}
