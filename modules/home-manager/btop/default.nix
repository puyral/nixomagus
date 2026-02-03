{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.btop;
in
{
  options.extra.btop = with lib; {
    enable = mkEnableOption "btop";
    gpuSupport = mkOption {
      type = types.nullOr (
        types.enum [
          "cuda"
          "rocm"
          "intel"
        ]
      );
      default = null;
      description = "Enable GPU support for specific vendor";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      package =
        if cfg.gpuSupport == "cuda" then
          pkgs.btop-cuda
        else if cfg.gpuSupport == "rocm" then
          pkgs.btop-rocm
        else
          # For Intel, 'make setcap' in the package build is not possible due to sandbox restrictions
          # and the immutability/no-capabilities nature of the nix store.
          # Users on NixOS should use security.wrappers if they need capabilities,
          # or run btop with sudo.
          pkgs.btop;
    };
  };
}
