{ lib, ... }:
{
  imports = [
    ./grafana.nix
    ./prometheus.nix
    ./loki.nix
    ./promtail.nix
  ];
  options.extra.monitoring = with lib; {
    enable = mkEnableOption "monitoring";
    grafana = {
      port = mkOption {
        default = 2342;
        type = types.port;
      };
      domain = mkOption {
        default = "graphana.puyral.fr";
        type = types.str;
      };
    };
    prometheus = {
      port = mkOption {
        default = 9001;
        type = types.port;
      };
    };
    loki = {
      port = mkOption {
        default = 3001;
        type = types.port;
      };
      dataDir = mkOption {
        default = "${config.params.locations.containers}/loki";
        type = type.path;
      };
    };
    promtail = {
      enable = mkEnableOption "promtail";
      lokiPort = mkOption {
        default = 3001;
        type = types.port;
      };
      lokiHost = mkOption {
        default = "dynas.puyral.fr";
        type = types.str;
      };
      port = mkOption {
        default = 28183;
        type = types.port;
      };
      name = mkOption { type = types.str; };
    };
  };
}
