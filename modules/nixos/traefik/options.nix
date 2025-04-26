lib:
with lib;
with builtins;
{
  enable = mkEnableOption "this reverse proxy rule";
  domain = mkOption {
    type = types.nullOr types.str;
    description = "the base domain";
    default = null;
  };
  port = mkOption {
    type = types.port;
    description = "the port to forward to";
  };
  container = mkOption {
    type = types.nullOr types.str;
    description = "the container name, if it's in a nixos container";
    default = null;
  };
  providers = mkOption {
    type = types.listOf types.str;
    description = "the machines that should do the redirect";
    default = [ "dynas" ];
  };
  address = mkOption {
    type = types.nullOr types.str;
    description = "the ip address";
    default = null;
  };
  extra = {
    rule = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };
}
