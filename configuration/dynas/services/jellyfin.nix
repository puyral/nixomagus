{ mconfig, ... }:
let
  base_dir = "/containers/jellyfin";
in
{
  containers.jellyfin = {
    bindMounts = {
      "/var/data/jellyfin" = {
        hostPath = "${base_dir}/data";
        isReadOnly = false;
      };
      "/var/cache/jellyfin" = {
        hostPath = "${base_dir}/cache";
        isReadOnly = false;
      };
      "/mnt/Zeno/media/videos" = {
        hostPath = "/mnt/Zeno/media/videos";
        isReadOnly = false;
      };
    };
    autoStart = true;

    config =
      { lib, ... }:
      {
        services.jellyfin = {
          enable = true;
          openFirewall = true;
        };
        services.jellyseerr.enable = true;

        system.stateVersion = mconfig.nixos;
        networking = {
          firewall.enable = true;
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        programs.nix-ld.enable = true;
        services.resolved.enable = true;
      };
  };
  networking.firewall = {
    allowedTCPPorts = [
      8096
      8920
    ];
    allowedUDPPorts = [
      1900
      7359
    ];
  };

}
