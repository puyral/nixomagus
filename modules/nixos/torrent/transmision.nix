{ config, lib, ... }:
with lib;
let
  cfg = config.extra.torrent;
in
{
  config = {
    services.transmission = mkIf (cfg.enable && !cfg.containered && cfg.transmission) (
      with cfg;
      # if cfg.containered then
      #   { }
      # else
      {
        enable = true;
        # home = "${dataDir}/transmission";
        settings = {
          download-dir = downloadDir;
          incomplete-dir = downloadDir;
          incomplete-dir-enabled = false;
          rpc-bind-address = "0.0.0.0";
          # rpc-whitelist = "*.*.*.*";
          rpc-whitelist-enabled = false;
          rpc-host-whitelist-enabled = false;
        };
        openFirewall = true;
        openRPCPort = true;
      }
      // (if cfg.user == null then { } else { user = cfg.user; })
      // (if cfg.group == null then { } else { group = cfg.group; })
    );

    # https://github.com/NixOS/nixpkgs/issues/258793
    systemd.services.transmission.serviceConfig = {
      RootDirectoryStartOnly = lib.mkForce false;
      RootDirectory = lib.mkForce "";
      # PrivateMounts = lib.mkForce false;
      # PrivateUsers = lib.mkForce false;
    };

  };
}
