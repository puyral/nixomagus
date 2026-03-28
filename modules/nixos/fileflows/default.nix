{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.extra.fileflows;
in
{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    # Ensure the temp directory exists with correct permissions if it's separate
    systemd.tmpfiles.rules = [
      "d ${cfg.tempDir} 0777 root root -"
    ];

    virtualisation.oci-containers.containers.fileflows = {
      image = cfg.image;
      autoStart = false;
      ports = [ "5000:5000" ];

      volumes = [
        "${cfg.dataDir}:/app/Data"
        "${cfg.tempDir}:/temp"
      ]
      ++ (map (path: "${path}:${path}") cfg.mediaDirs);

      # Hardware Acceleration Logic
      extraOptions = optionals cfg.hardware.intelArc [
        "--device=/dev/dri:/dev/dri"
      ];
    };

    networking.nginx.instances.fileflows = lib.mkIf cfg.networking.reverproxied {
      port = 5000;
      # name = cfg.networking.name; # networking.nginx.instances uses the key as the subdomain name by default.
    };

    # networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 5000 ];
  };
}
