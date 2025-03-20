{ config, lib, ... }:
let
  cfg = config.extra.cache;

in
{
  config = lib.mkIf cfg.substituter {
    nix = {
      settings = {
        substituters = [
          "https://nix.dynas.puyral.fr/"
        ];
        trusted-public-keys = [
          (builtins.readFile ./secrets/cache-pub-key.pem)
        ];
      };
    };
  };
}
