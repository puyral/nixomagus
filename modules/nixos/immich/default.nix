{
  config,
  pkgs-unstable,
  pkgs,
  lib,
  ...
}:
let
  port = 2283;
  gconfig = config;
  cfg = config.extra.immich;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    networking.nat.internalInterfaces = [ "ve-immich" ];
    containers.immich = {
      bindMounts = {
        "/photos" = {
          hostPath = cfg.photos;
          isReadOnly = true;
        };
        "/var/lib/tailscale" = {
          hostPath = "${cfg.dataDir}/tailscale";
          isReadOnly = false;
        };
        "/var/lib/immich" = {
          hostPath = "${cfg.dataDir}/state";
          isReadOnly = false;
        };
        "/var/cache/immich" = {
          hostPath = "${cfg.dataDir}/cache";
          isReadOnly = false;
        };
        "/var/lib/postgresql" = {
          hostPath = "${cfg.dataDir}/postgresql";
          isReadOnly = false;
        };
      };
      autoStart = true;
      ephemeral = true;

      config =
        { ... }:
        let
          user = "immich";
        in
        {
          environment.systemPackages =
            (with pkgs-unstable; [
              darktable
              #{ inherit darktable gen-config; })
            ])
            ++ (with pkgs; [
              ffmpeg
              exiftool
            ]);

          services.immich = {
            inherit port;
            enable = true;
            user = user;
            group = user;
            openFirewall = true;
            host = "0.0.0.0";
          };

          users.users.${user} = {
            group = user;
            isSystemUser = true;
          };
          users.groups.${user}.gid = gconfig.users.groups.photos.gid;

          services.tailscale.enable = true;
        };
    };
    extra.containers.immich = {
      vpn = true;

      traefik = [
        {
          inherit port;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.providers;
          address = "100.64.0.8";
        }
      ];
    };
    users.groups.photos = {
      members = [
        "simon"
        "root"
      ];
      gid = 984;
    };
  };
}
