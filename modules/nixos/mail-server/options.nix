{ lib, ... }:
{
  options.extra.mail-server = with lib; {
    enable = mkEnableOption "mail-server";
    domain = mkOption {
      type = types.str;
      default = "puyral.fr";
      description = "the domain for the email addresses";
    };
  };
}
