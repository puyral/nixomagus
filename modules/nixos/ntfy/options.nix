{ lib, config, ... }:
{
  options.extra.ntfy = with lib; {
    enable = mkEnableOption "ntfy";

    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/ntfy";
    };
    url = mkOption {
      type = types.str;
    };
  };
}
