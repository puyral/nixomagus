{ lib, ... }: {
  options.extra.copyparty = with lib; {
    enable = mkEnableOption "copyparty";
    port = mkOption {
      type = types.port;
      default = 7898;
    };
    subdomain = mkOption {
      type = types.str;
      default = "copyparty";
    };
  };
}
