{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.nix-ld;
in
{
  options.extra.nix-ld.enable = lib.mkEnableOption "nix-ld";

  config = lib.mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # List by default
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd

      ];
    };
  };
}
