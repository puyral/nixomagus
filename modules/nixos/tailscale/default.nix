{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.tailscale;
in
{
  options.extra.tailscale = with lib; {
    enable = mkEnableOption "tailscale";
    trustVPN = mkOption {
      type = types.bool;
      default = true;
    };
    exitNode = {
      enable = mkEnableOption "exit node";
      interfaces = mkOption {
        type = with types; listOf str;
      };
      ruleName = mkOption {
        type = types.str;
        default = "50-tailscale";
      };
    };
    subnet = {
      addr = mkOption {
        type = types.str;
      };
      size = mkOption {
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      tsinterface = config.services.tailscale.interfaceName;
    in
    {
      extra.tailscale.subnet = {
        addr = "100.64.0.0";
        size = "10";
      };

      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = if cfg.exitNode.enable then "server" else "client";
      };
      networking.firewall.trustedInterfaces = lib.mkIf cfg.trustVPN [ tsinterface ];

      services.networkd-dispatcher = lib.mkIf cfg.exitNode.enable (
        let
          eachInterface = interface: ''
            ${lib.getExe pkgs.ethtool} -K ${interface} rx-udp-gro-forwarding on rx-gro-list off
          '';
          script = lib.concatMapStringsSep "\n" eachInterface cfg.exitNode.interfaces;
        in
        {
          enable = true;
          rules."${cfg.exitNode.ruleName}" = {
            inherit script;
            onState = [ "routable" ];
          };
        }
      );
    }
  );
}
