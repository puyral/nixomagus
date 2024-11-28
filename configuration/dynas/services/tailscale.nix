{ lib, pkgs, ... }:
let
  interface = "enp9s0";
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
