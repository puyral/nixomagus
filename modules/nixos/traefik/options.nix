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
}
