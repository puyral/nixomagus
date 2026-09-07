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
          isReadOnly = false;
        };
        "/videos" = {
          hostPath = cfg.videos;
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
        { pkgs-unstable, ... }:
        let
          user = "immich";
        in
        {
          environment.systemPackages = (
            with pkgs;
            [
              ffmpeg
              exiftool
              darktable
            ]
          );

          services.immich = {
            inherit port;
            enable = true;
            # immich 3.x only exists in nixpkgs-unstable (not 26.05);
            # the services.immich module is unchanged between them, so just
            # override the package (module version is 2.7.5 on stable).
            package = pkgs-unstable.immich;
            user = user;
            group = user;
            openFirewall = true;
            host = "0.0.0.0";
          };

          users.users.${user} = {
            group = user;
            isSystemUser = true;
            extraGroups = [
              "render"
              "video"
            ];
          };
          users.groups.${user}.gid = gconfig.users.groups.photos.gid;
          users.groups."render".gid = gconfig.users.groups."render".gid;
          users.groups."video".gid = gconfig.users.groups."video".gid;

        };
    };
    extra.containers.immich = {
      vpn = false;
      gpu = true;

      nginx = [
        {
          inherit port;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.providers;
          extraConfig = ''
            client_max_body_size 0;
          '';
          gzip-bomb.enable = true;
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
