{ ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global.security = "user";
      # nmbd.enable = false;
      # winbindd.enable = false;
      # extraConfig = ''
      #   guest account = simon
      #   map to guest = Bad User

      #   load printers = no
      #   printcap name = /dev/null

      #   log file = /var/log/samba/client.%I
      #   log level = 2
      # '';

      Zeno = {
        "path" = "/mnt/Zeno";
        "guest ok" = "no";
        "read only" = "no";
        "veto files" = "/._*/.DS_Store/";
        "delete veto files" = "yes";
      };
    };
  };
}
