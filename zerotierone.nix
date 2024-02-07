{ config, lib, pkgs, ... }:

{

  services.zerotierone =
    let networks = import ./secrets/zerotier-networks.nix; in
    {
      enable = true;
      joinNetworks = networks.vidya.id;
    };
}
