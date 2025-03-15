{ pkgs, lib, config, ... }:
with lib;
let cfg = config.extra.mpris-proxy; in
{
  options.extra.mpris-proxy.enable = mkEnableOption "mpris-proxy";
  config = mkIf cfg.enable
{
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    # after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  home.packages = with pkgs; [ bluez ];
};}
