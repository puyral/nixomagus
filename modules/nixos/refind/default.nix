{
  pkgs,
  lib,
  config,
  ...
}:
let
  archids = {
    x86_64-linux = {
      hostarch = "x86_64";
      efiPlatform = "x64";
    };
    i686-linux = rec {
      hostarch = "ia32";
      efiPlatform = hostarch;
    };
    aarch64-linux = {
      hostarch = "aarch64";
      efiPlatform = "aa64";
    };
  };

  inherit
    (archids.${pkgs.stdenv.hostPlatform.system}
      or (throw "unsupported system: ${pkgs.stdenv.hostPlatform.system}")
    )
    hostarch
    efiPlatform
    ;
in
{
  options.extra.refind.enable = lib.mkEnableOption "refind";

  config.boot.loader.systemd-boot = lib.mkIf config.extra.refind.enable {
    extraFiles = {
      "efi/refind/refind_${efiPlatform}.efi" = "${pkgs.refind}/share/refind/refind_${efiPlatform}.efi";
    };
    extraEntries = {
      "refind.conf" = ''
        title rEFInd
        efi /efi/refind/refind_${efiPlatform}.efi
        sort-key z_refind
      '';
    };
  };

}
