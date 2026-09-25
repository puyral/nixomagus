{ lib, ... }:
{
  options.extra.acme = with lib; {
    enable = mkEnableOption "acme";
    domain = mkOption {
      type = types.str;
      default = "puyral.fr";
    };
    extraDomains = mkOption {
      type = types.listOf types.str;
      description = "extra domain names / wildcards to add as SANs of the ACME cert";
      default = [ ];
    };
  };
}
