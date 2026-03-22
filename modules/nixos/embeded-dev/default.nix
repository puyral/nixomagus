{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.embeded-dev;
in
{
  options.extra.embeded-dev = with lib; {
    enable = mkEnableOption "embeded dev tweaks";
    users = mkOption {
      type = types.listOf types.str;
      default = [ "simon" ];
    };
  };
  config = lib.mkIf cfg.enable {

    users.users =
      with lib;
      listToAttrs (
        map (u: {
          name = u;
          value = {
            extraGroups = [
              "dialout"
              "plugdev"
            ];
          };
        }) cfg.users
      );

    services.udev.extraRules = builtins.readFile (
      pkgs.fetchurl {
        url = "https://probe.rs/files/69-probe-rs.rules";
        hash = "sha256-yjxld5ebm2jpfyzkw+vngBfHu5Nfh2ioLUKQQDY4KYo=";
      }
    );
  };
}
