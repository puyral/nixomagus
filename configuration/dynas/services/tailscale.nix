{
  lib,
  pkgs,
  config,
  ...
}:
let
  interface = config.vars.mainNetworkInterface;
in
{
  services.tailscale = {
    # enable = true;
    # ^^^^^^^^^^^^^^ already enabled

    useRoutingFeatures = "server";
  };

  services = {
    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          ${lib.getExe pkgs.ethtool} -K ${interface} rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
}
