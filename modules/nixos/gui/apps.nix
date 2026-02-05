{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.gui;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ gparted ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
