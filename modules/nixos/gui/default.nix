{ config, lib, ... }:
let
  cfg = config.extra.gui;
in

{
  imports = [
    ./options.nix
    ./i3.nix
    ./hyprland.nix
    ./apps.nix
    ./gnome.nix
    ./sway.nix
  ];

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    security.polkit.enable = true;
    # https://nixos.wiki/wiki/Visual_Studio_Code#Error_after_Sign_On
    services.gnome.gnome-keyring.enable = true;

    extra.printing.enable = true;
  };
}
