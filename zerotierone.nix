{ config, lib, pkgs, ... }:

{
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "8bd5124fd63a17e4" ];
  };
}
