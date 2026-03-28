{
  config,
  pkgs,
  lib,
  computer,
  ...
}:
let
  cfg = config.extra.jellyfin;
  name = "jellyfin";
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable (
    let
      localAddress = config.containers.${name}.localAddress;
      entrypoint = name;
    in
    {
      containers.${name} = {
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
          # gpu - existing jellyfin config had all of /dev/dri
          # "/dev/dri" = {
          #   hostPath = "/dev/dri";
          #   isReadOnly = false;
          # };
        };
      };

      extra.containers.${name} = {
        gpu = true;
        privateNetwork = false;
        # Do NOT use traefik option here as per user request
      };

      # The container configuration itself
      containers.${name}.config =
        { lib, pkgs, ... }:
        {
          services.jellyfin = {
            enable = true;
            openFirewall = true;
            user = "jellyfin";
          };
          services.jellyseerr.enable = true;

          system.stateVersion = computer.stateVersion;
          networking = {
            firewall.enable = true;
            useHostResolvConf = lib.mkForce false;
          };

          programs.nix-ld.enable = true;
          services.resolved.enable = true;
          # We need to make sure these users/groups exist or are inherited
          # In the original, they were assigned from config.users.users.jellyfin
          # which refers to the HOST users.
          users.users.jellyfin = config.users.users.jellyfin;
          users.groups.jellyfin.gid = config.users.groups.jellyfin.gid;
          users.groups."render".gid = config.users.groups."render".gid;
          users.groups."video".gid = config.users.groups."video".gid;

          systemd.services.jellyfin.serviceConfig.DeviceAllow = [ "/dev/dri/renderD128" ];

          hardware.graphics = {
            enable = true;
            extraPackages = with pkgs; [
              intel-media-driver
              vpl-gpu-rt
              intel-compute-runtime
            ];
          };
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

      # Manual Traefik configuration as it was in the original
      # services.traefik.staticConfigOptions.entryPoints.${entrypoint} = ":9999";

      # services.traefik.dynamicConfigOptions.http = {
      #   routers.${name} = {
      #     rule = "Host(`${name}.puyral.fr`)";
      #     entrypoints = entrypoint;
      #     tls = {
      #       certResolver = "ovh";
      #       domains = "${name}.puyral.fr";
      #     };
      #     middlewares = "${name}";
      #     service = "${name}";
      #   };
      #   middlewares.${name} = {
      #     headers = {
      #       customResponseHeaders.X-Robots-Tag = [
      #         "noindex"
      #         "nofollow"
      #         "nosnippet"
      #         "noarchive"
      #         "notranslate"
      #         "noimageindex"
      #       ];
      #       SSLRedirect = true;
      #       SSLHost = "${name}.puyral.fr:9999";
      #       SSLForceHost = true;
      #       STSSeconds = 315360000;
      #       STSIncludeSubdomains = true;
      #       STSPreload = true;
      #       forceSTSHeader = true;
      #       frameDeny = true;
      #       contentTypeNosniff = true;
      #       customresponseheaders.X-XSS-PROTECTION = 1;
      #       customFrameOptionsValue = "allow-from https://puyral.fr";
      #     };
      #   };
      #   services.${name} = {
      #     loadBalancer = {
      #       servers = [ { url = "http://${localAddress}:8096"; } ];
      #       passHostHeader = true;
      #     };
      #   };

      #   routers."${name}-insecure" = {
      #     rule = config.services.traefik.dynamicConfigOptions.http.routers.${name}.rule;
      #     entrypoints = "${entrypoint}";
      #     middlewares = "${name}-insecure";
      #     service = "noop@internal";
      #   };
      #   middlewares."${name}-insecure".redirectscheme = {
      #     scheme = "https";
      #     port = 9999;
      #     permanent = false;
      #   };
      # };

      networking.firewall.allowedTCPPorts = [
        9999
        8096
        8920
      ];
    }
  );
}
