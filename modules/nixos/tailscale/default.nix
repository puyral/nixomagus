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
  };

  config = lib.mkIf cfg.enable (
    let
      tsinterface = config.services.tailscale.interfaceName;
    in
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = lib.mkIf cfg.exitNode.enable "server";
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
