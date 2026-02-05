{ lib, ... }:
{
  options.extra.acme = with lib; {
    enable = mkEnableOption "acme";
    domain = mkOption {
      type = types.str;
      default = "puyral.fr";
    };
  };
}
