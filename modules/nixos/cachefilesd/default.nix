{ lib, config, ... }:
let
  cfg = config.extra.cachefilesd;
in
{
  options.extra.cachefilesd = {
    enable = lib.mkEnableOption "cachefilesd";
    cacheDir =
      with lib;
      mkOption {
        type = types.path;
        default = "/var/cache/fscache";
      };
  };
  config.services.cachefilesd = lib.mkIf cfg.enable {
    enable = true;
    cacheDir = cfg.cacheDir;
    # extraConfig = ''
    #   # Taille maximale du cache
    #   brun 20%
    #   bcull 15%

    #   # Paramètres pour l'écriture différée
    #   wrun 10%
    #   wcull 5%

    #   # Délai de validation (non directement supporté, ajustez d'autres paramètres)
    #   # timeout n'est pas un paramètre standard de cachefilesd
    # '';

  };
}
