{ config, ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        security = "user";
        "log level" = "3";

      };
      # nmbd.enable = false;
      # winbindd.enable = false;
      # extraConfig = ''
      # #   guest account = simon
      # #   map to guest = Bad User

      # #   load printers = no
      # #   printcap name = /dev/null

      # #   log file = /var/log/samba/client.%I
      # '';

      Zeno = {
        "path" = config.vars.Zeno.mountPoint;
        "guest ok" = "no";
        "read only" = "no";
        "veto files" = "/._*/.DS_Store/";
        "delete veto files" = "yes";
        "case sensitive" = "yes";
      };
    };
  };

  services.nfs = {
    server.enable = true;
  };
  networking.firewall.allowedTCPPorts = [ 2049 ];
}
