{...}:{
  networking = {
    nat = {
      enable = true;
      externalInterface = "ens3";
    };
    traefik = {
      enable = true;
      baseDomain = "puyral.fr";
      # docker.enable = true;
      log.level = "INFO";
    };
  };
}