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

    virtualisation.oci-containers.containers.fileflow = {
      image = cfg.image;
      autoStart = true;

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

    virtualisation.oci-containers.proxy.containers.fileflow = lib.mkIf cfg.networking.reverproxied {
      port = 5000;
      extraConfig = ''
        client_max_body_size 200M;
      '';
    };

    # networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 5000 ];
  };
}
