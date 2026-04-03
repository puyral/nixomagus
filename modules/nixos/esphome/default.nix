{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.esphome;
  # mqtt_port = (builtins.head config.services.mosquitto.listeners).port;
  # mqtt = "mqtt://localhost:${builtins.toString mqtt_port}";

in
{
  options.extra.esphome = with lib; {
    enable = mkEnableOption "esphome";
    address = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.esphome = {
      enable = true;
      address = cfg.address;
      openFirewall = true;
    };

    # see https://github.com/NixOS/nixpkgs/issues/339557#issuecomment-3361954390
    systemd.services.esphome.serviceConfig = {
      ProtectSystem = lib.mkForce "off";
      DynamicUser = lib.mkForce "false";
      User = "esphome";
      Group = "esphome";
    };
    users.users.esphome = {
      isSystemUser = true;
      home = "/var/lib/esphome";
      group = "esphome";
    };
    users.groups.esphome = { };
  };
}
