{ lib, config, ... }: {

  options.extra.homeassistant = with lib; {
    enable = mkEnableOption "homeassistant";
    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/homeassistant";
    };
  };
}
