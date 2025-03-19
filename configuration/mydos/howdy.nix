{
  pkgs,
  pkgs-unstable,
  my-nixpkgs,
  lib,
  ...
}:
let
  howdypatches = builtins.map (e: "${my-nixpkgs}/${e}") [
    "nixos/modules/services/misc/linux-enable-ir-emitter.nix"
    "nixos/modules/services/security/howdy"
  ];
in

{
  imports = howdypatches;

  nixpkgs.config.overlays = [ ] ++ [
    (self: super: {
      howdy = pkgs.callPackage "${my-nixpkgs}/pkgs/by-name/ho/howdy/package.nix" { };
      linux-enable-ir-emitter =
        pkgs.callPackage "${my-nixpkgs}/pkgs/by-name/li/linux-enable-ir-emitter/package.nix"
          { };
    })
  ];

  services.howdy = {
    enable = false;
    settings.video.device_path = "/dev/video4";
  };
  services.linux-enable-ir-emitter = {
    enable = false;
    device = "video4";
  };
  environment.systemPackages = [ pkgs.linux-enable-ir-emitter ];
}
