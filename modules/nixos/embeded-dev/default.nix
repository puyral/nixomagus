{
  config,
  lib,
  pkgs-self,
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
    users.groups.plugdev = {
      members = [ "root" ];
    };

    services.udev.packages = [ pkgs-self.probe-rs-udev ];
  };
}
