{
  mconfig,
  config,
  pkgs-unstable,
  rootDir,
  ...
}:
let
  # entrypoint = name;
  # localAddress = config.containers.${name}.localAddress;
  port = 2342;
  gconfig = config;
in
{
  networking.nat.internalInterfaces = [ "ve-photos" ];
  # networking.reverse_proxy."photo" = {
  #   container = "photoprism";
  #   inherit port;
  # };
  containers.photoprism = {
    bindMounts = {
      "/Volumes/Zeno/media/photos" = {
        hostPath = "/mnt/Zeno/media/photos";
        isReadOnly = true;
      };
      "/originals" = {
        hostPath = "/mnt/Zeno/media/photos/exports/complete";
        isReadOnly = false;
      };
      "/cache" = {
        hostPath = "/containers/photoprism";
        isReadOnly = false;
      };
    };
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "192.168.1.3";
    localAddress = "192.168.100.12";

    config =
      { lib, config, ... }:
      {

        environment.systemPackages = with pkgs-unstable; [ darktable ];
        services.photoprism = {
          enable = true;
          originalsPath = "/originals";
          storagePath = "/cache";
          passwordFile = ./secrets/password;
          settings = {
            PHOTOPRISM_ADMIN_USER = "root";
          };
          inherit port;
          address = "0.0.0.0";
        };

        system.stateVersion = mconfig.nixos;
        networking = {
          firewall.enable = false;
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        # users.users.simon= gconfig.users.users.simon;
        # programs.zsh.enable = true;
        # systemd.services.photoprism.serviceConfig= {
        #   User = lib.mkForce  "simon";
        #   Group = lib.mkForce  "photoprism";
        # };
        users.users.photoprism = {
          group = "photoprism";
          isSystemUser = true;
        };
        users.groups.photoprism.gid = gconfig.users.groups.photoprism.gid;

        # users.users."root".openssh.authorizedKeys.keys =
        #   config.users.users."root".openssh.authorizedKeys.keys;
        services.openssh = {
          enable = true;
          # openFirewall = true;
        };

        services.resolved.enable = true;
        nixpkgs.config.allowUnfree = true;

        services.zerotierone =
          let
            networks = import (rootDir + /secrets/zerotier-networks.nix);
          in
          {
            enable = true;
            joinNetworks = [ networks.vidya.id ];
          };
      };
  };
  users.groups.photoprism = {
    members = [
      "simon"
      "root"
    ];
    gid = 986;
  };
}
