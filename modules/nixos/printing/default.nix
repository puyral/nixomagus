{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.extra.printing;
in
{
  options.extra.printing.enable = lib.mkEnableOption "printing configuration";
  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # or got to http://localhost:631
    environment.systemPackages = with pkgs; [ system-config-printer ];
  };
}
