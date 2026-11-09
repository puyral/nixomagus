{ lib, ... }:
{
  options.extra.remoteDarktable = with lib; {
    enable = mkEnableOption "remote darktable";
    resolution = mkOption {
      type = types.str;
      default = "2560x1600@60Hz scale 2";
    };
    port = mkOption {
      type = types.port;
      default = 5900;
    };
  };
}
