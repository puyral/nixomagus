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
    };

    extra.containers.${name} = {
      gpu = true;
      privateNetwork = false;
      # Do NOT use traefik option here as per user request
    };

    # The container configuration itself
    containers.${name}.config =
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

    networking.firewall.allowedTCPPorts = [
      9999
      8096
      8920
    ];
  });
}
