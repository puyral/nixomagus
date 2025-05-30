{ self, ... }:
{
  networking = {
    nat = {
      enable = true;
      externalInterface = "ens3";
    };
    traefik = {
      enable = true;
      baseDomain = "puyral.fr";
      # docker.enable = true;
      # log.level = "DEBUG";
      instances = self.nixosConfigurations.dynas.config.networking.traefik.instances;
    };
  };
  extra = {
    headscale = {
      enable = true;
      extraDomain = "headscale";
    };
    authelia = {
      enable = true;
    };
  };
}
