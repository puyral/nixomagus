{ computer, config, ... }:
let
  name = "jellyfin";
  base_dir = "${config.params.locations.containers}/${name}";
  entrypoint = name;
  localAddress = config.containers.${name}.localAddress;
in
{
  networking.nat.internalInterfaces = [ "ve-jf" ];
  containers.${name} = {
    bindMounts = {
      "/var/lib/jellyfin" = {
        hostPath = "${base_dir}/data";
        isReadOnly = false;
      };
      "/var/cache/jellyfin" = {
        hostPath = "${base_dir}/cache";
        isReadOnly = false;
      };
      "/videos" = {
        hostPath = "${config.vars.Zeno.mountPoint}/media/videos";
        isReadOnly = false;
      };

      # gpu
      "/dev/dri" = {
        hostPath = "/dev/dri";
        isReadOnly = false;
      };
    };
    allowedDevices = [
      {
        node = "/dev/dri/renderD128";
        modifier = "rw";
      }
    ];
    autoStart = true;
    ephemeral = true;
    privateNetwork = false;
    hostAddress = "192.168.1.2";
    localAddress = "192.168.100.11";

    # I'm using ACLs to let jellyfin have access to the media
    # see `getfacl` and `setfacl`

    config =
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
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        programs.nix-ld.enable = true;
        services.resolved.enable = true;
        users.users.jellyfin = config.users.users.jellyfin;
        users.groups.jellyfin.gid = config.users.groups.jellyfin.gid;
        users.groups."render".gid = config.users.groups."render".gid;
        users.groups."video".gid = config.users.groups."video".gid;

        # 4. Allow systemd to see the devices
        systemd.services.jellyfin.serviceConfig.DeviceAllow = [ "/dev/dri/renderD128" ];

        # 2. Enable Graphics inside the container
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver # The iHD driver for QSV
            vpl-gpu-rt # Video Processing Library (Critical for Arc/Battlemage)
            intel-compute-runtime # OpenCL (Optional for Jellyfin, good for HDR tone mapping)
          ];
        };
      };
  };

  users.users = {
    jellyfin = {
      isSystemUser = true;
      uid = 1101;
      group = "jellyfin";
      extraGroups = [
        "render"
        "video"
      ];
    };
  };
  extra.extraGroups.jellyfin = {
    gid = 1100;
  };

  services.traefik.staticConfigOptions.entryPoints.${entrypoint} = ":9999";

  services.traefik.dynamicConfigOptions.http = {
    # HTTP Router
    routers.${name} = {
      # Host or Path where Jellyfin is accessible Remove (or change) this rule
      # if you'd rather have Jellyfin accessible at a PathPrefix URI
      rule = "Host(`${name}.puyral.fr`)";
      # Entry point where Jellyfin is accessible via Change secure to https in
      # the line below to have accessible without needing to specify a port and
      # change the SSLHost option below
      entrypoints = entrypoint;
      # Enable TLS with the ACME/LetsEncrypt resolver for ${name}.puyral.fr
      tls = {
        certResolver = "ovh";
        domains = "${name}.puyral.fr";
      };
      middlewares = "${name}";
      service = "${name}";
    };
    # Middleware
    middlewares.${name} = {
      headers = {
        # The customResponseHeaders option lists the Header names and values to
        # apply to the response.
        customResponseHeaders.X-Robots-Tag = [
          "noindex"
          "nofollow"
          "nosnippet"
          "noarchive"
          "notranslate"
          "noimageindex"
        ];
        # The sslRedirect is set to true, then only allow https requests.
        SSLRedirect = true;
        # The sslHost option is the host name that is used to redirect http
        # requests to https. This is the exact URL that will be redirected to,
        # so you can remove the :9999 port if using default SSL port
        SSLHost = "${name}.puyral.fr:9999";
        # Set sslForceHost to true and set SSLHost to forced requests to use
        # SSLHost even the ones that are already using SSL.
        # Note that this uses SSLHost verbatim, so add the port to SSLHost if
        # you are using an alternate port.
        SSLForceHost = true;
        # The stsSeconds is the max-age of the Strict-Transport-Security header.
        # If set to 0, would NOT include the header.
        STSSeconds = 315360000;
        # The stsIncludeSubdomains is set to true, the includeSubDomains directive
        # will be appended to the Strict-Transport-Security header.
        STSIncludeSubdomains = true;
        # Set stsPreload to true to have the preload flag appended to the
        # Strict-Transport-Security header.
        STSPreload = true;
        # Set forceSTSHeader to true, to add the STS header even when the connection is HTTP.
        forceSTSHeader = true;
        # Set frameDeny to true to add the X-Frame-Options header with the value of DENY.
        frameDeny = true;
        # Set contentTypeNosniff to true to add the X-Content-Type-Options header
        # with the value nosniff.
        contentTypeNosniff = true;
        # Set browserXssFilter to true to add the X-XSS-Protection header with
        # the value 1; mode=block.
        customresponseheaders.X-XSS-PROTECTION = 1;
        # The customFrameOptionsValue allows the X-Frame-Options header value
        # to be set with a custom value. This overrides the FrameDeny option.
        customFrameOptionsValue = "allow-from https://puyral.fr";
      };
    };
    services.${name} = {
      loadBalancer = {
        servers = [ { url = "http://${localAddress}:8096"; } ];
        passHostHeader = true;
      };

      ## HTTP Service
      # We define the port here as a port is required, but note that the service is pointing to the service defined in @file
      # - 'traefik.http.services.jellyfin-svc.loadBalancer.server.port=8096'
      # - 'traefik.http.services.jellyfin-svc.loadBalancer.passHostHeader=true'
      ## Redirection of HTTP on port 9999 to HTTPS on port 9999 (consistent protocol)
      # - 'traefik.http.routers.jellyfin-insecure.entryPoints=secure'
      # - 'traefik.http.routers.jellyfin-insecure.rule=Host(`HOST_NAME.DOMAIN_NAME`)' # OPTIONAL: && PathPrefix(`/jellyfin`)
      # - 'traefik.http.routers.jellyfin-insecure.middlewares=jellyfin-insecure-mw'
      # - 'traefik.http.middlewares.jellyfin-insecure-mw.redirectscheme.scheme=https'
      # - 'traefik.http.middlewares.jellyfin-insecure-mw.redirectscheme.port=9999' # remove if you are using a default port
      # - 'traefik.http.middlewares.jellyfin-insecure-mw.redirectscheme.permanent=false'
      # - 'traefik.http.routers.jellyfin-insecure.service=noop@internal'
    };

    routers."${name}-insecure" = {
      rule = config.services.traefik.dynamicConfigOptions.http.routers.${name}.rule;
      entrypoints = "${entrypoint}";
      middlewares = "${name}-insecure";
      service = "noop@internal";
    };
    middlewares."${name}-insecure".redirectscheme = {
      scheme = "https";
      port = 9999;
      permanent = false;
    };

  };

  # services.traefik.dynamicConfigOptions.http =
  #   let
  #     mkConfig = name: port: {
  #       routers.${name} = {
  #         rule = "Host(`${name}.puyral.fr`)";
  #         entrypoints = "https";
  #         tls.certResolver = "ovh";
  #         service = name;
  #       };
  #       services.${name} = {
  #         loadBalancer.servers = [ { url = "http://${config.containers.ha.localAddress}:${builtins.toString port}"; } ];
  #       };
  #     };
  #   in
  #   pkgs.lib.attrsets.recursiveUpdate (mkConfig "homeassistant" 8123) (mkConfig "zigbee2mqtt" z2m_port);
  networking.firewall = {
    allowedTCPPorts = [
      9999
      8096
      8920
    ];
    # allowedUDPPorts = [
    #   1900
    #   7359
    # ];
  };

}
