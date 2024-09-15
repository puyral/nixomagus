{...}:{
  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    extraConfig = ''
      guest account = simon
      map to guest = Bad User

      load printers = no
      printcap name = /dev/null

      log file = /var/log/samba/client.%I
      log level = 2
    '';

    # shares = {
    #   nas = {
    #     "path" = "/mnt";
    #     "guest ok" = "yes";
    #     "read only" = "no";
    #   };
    # };
  };
}