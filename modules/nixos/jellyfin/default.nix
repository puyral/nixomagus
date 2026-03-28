{
  config,
  lib,
  ...
}:
let
  cfg = config.extra.jellyfin;
  name = "jellyfin";
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable ({
    containers.${name} = {
      privateNetwork = true;
      bindMounts = {
        "/var/lib/jellyfin" = {
          hostPath = "${cfg.dataDir}/data";
          isReadOnly = false;
        };
        "/var/cache/jellyfin" = {
          hostPath = "${cfg.dataDir}/cache";
          isReadOnly = false;
        };
        "/videos" = {
          hostPath = cfg.videoDir;
          isReadOnly = false;
        };
      };
      config =
        { ... }:
        {
          services.jellyfin = {
            enable = true;
            openFirewall = true;
            user = "jellyfin";
          };
          services.jellyseerr.enable = true;

          programs.nix-ld.enable = true;
          # We need to make sure these users/groups exist or are inherited
          # In the original, they were assigned from config.users.users.jellyfin
          # which refers to the HOST users.
          users.users.jellyfin = config.users.users.jellyfin;
          users.groups.jellyfin.gid = config.users.groups.jellyfin.gid;
          users.groups."render".gid = config.users.groups."render".gid;
          users.groups."video".gid = config.users.groups."video".gid;

          systemd.services.jellyfin.serviceConfig.DeviceAllow = [ "/dev/dri/renderD128" ];
        };
    };

    extra.containers.${name} = {
      gpu = true;
      nginx = [
        {
          enable = true;
          port = 8096;
          name = "jellyfin";
          extraConfig = ''
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            client_max_body_size 100M;

            # Security / XSS Mitigation Headers
            add_header X-Content-Type-Options "nosniff";
            add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;
            add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; font-src 'self'";
          '';
        }
        {
          enable = true;
          port = 8096;
          name = "jellyfin-socket";
          subdomain = "jellyfin";
          path = "/socket";
        }
        {
          enable = true;
          port = 5055;
          name = "seerr";
        }
      ];
    };

    users.users.jellyfin = {
      isSystemUser = true;
      uid = 1101;
      group = "jellyfin";
      extraGroups = [
        "render"
        "video"
      ];
    };
    extra.extraGroups.jellyfin = {
      gid = 1100;
    };
  });
}
