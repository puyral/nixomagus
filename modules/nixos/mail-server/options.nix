{ lib, ... }:
let
  str = lib.mkOption { type = lib.types.str; };
in
{
  options.extra.mail-server = with lib; {
    enable = mkEnableOption "mail-server";
    domain = mkOption {
      type = types.str;
      default = "puyral.fr";
      description = "the domain for the email addresses";
    };

    remoteStorage = {
      enable = mkEnableOption "remote mail storage";
      remote = {
        ip = str;
        path = str;
      };
      local = {
        base = str;
        storage = str;
      };
    };
  };
}
