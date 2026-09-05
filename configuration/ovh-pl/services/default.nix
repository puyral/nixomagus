{
  self,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ];

  networking = {
    nat = {
      enable = true;
      externalInterface = "ens3";
    };
    nginx = {
      enable = true;
      # docker.enable = true;
      # log.level = "DEBUG";
      instances = self.nixosConfigurations.dynas.config.networking.nginx.instances;
    };
    firewall.allowedTCPPorts = [ 222 ];
  };

  # Forward forgejo SSH (port 222) to dynas.
  # Note: SSH does not send the hostname in the protocol, so this redirect
  # applies to ALL traffic on port 222 regardless of the hostname used
  # (git.puyral.fr or otherwise) - hostname-based routing is not possible for SSH.
  systemd.services.forgejo-ssh-forward = {
    description = "Forward forgejo SSH port 222 to dynas";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:222,fork,reuseaddr TCP:${config.ips.dynas}:222";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  services.rustdesk-server = {
    enable = false;
    openFirewall = true;
  };
  systemd.services.rustdesk-signal = lib.mkIf config.services.rustdesk-server.enable {
    serviceConfig.ExecStart = lib.mkForce "${config.services.rustdesk-server.package}/bin/hbbs";
  };
  extra = {
    acme.enable = true;
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
