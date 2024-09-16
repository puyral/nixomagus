{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  # Shorter name to access final settings a 
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.virtualisation.superDocker;
in
{
  # Declare what settings a user of this "hello.nix" module CAN SET.
  options.services.hello = {
    enable = mkEnableOption "a better docker module";
    storageDriver = mkOption {
      type = types.nullOr (
        types.enum [
          "aufs"
          "btrfs"
          "devicemapper"
          "overlay"
          "overlay2"
          "zfs"
        ]
      );
      default = "btrf";
    };
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module 
  # by setting "services.hello.enable = true;".
  config = mkIf cfg.enable {
    # systemd.services.hello = {
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig.ExecStart = "${pkgs.hello}/bin/hello -g'Hello, ${escapeShellArg cfg.greeter}!'";
    # };

    virtualisation.docker = {
      enable = true;
      storageDriver = cfg.storageDriver;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
