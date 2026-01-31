{lib,  ...}:{
  options.ips = with lib;
    mkOption {
      type = types.attrsOf types.str;
    };
  config.ips = import ./sercrets/ip.nix;
}