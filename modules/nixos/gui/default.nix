{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.gui;
  newWlrInUse = lib.strings.concatStringsSep ";" cfg.extraWlrInUse;
in

{
  imports = [
    ./options.nix
    ./i3.nix
    ./hyprland.nix
    ./apps.nix
    ./gnome.nix
    ./sway.nix
    ./mangowc.nix
  ];

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = lib.mkIf (cfg.extraWlrInUse != [ ]) [
      (final: prev: {
        xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            sed -i 's/UseIn=wlroots;/UseIn=${newWlrInUse};wlroots;/' $out/share/xdg-desktop-portal/portals/wlr.portal
          '';
        });
      })
    ];

    services.xserver.enable = true;
    security.polkit.enable = true;
    # https://nixos.wiki/wiki/Visual_Studio_Code#Error_after_Sign_On
    services.gnome.gnome-keyring.enable = true;

    extra.printing.enable = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      # FIXME -- shouldn't be needed
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config = {
        # common.default = [ "gtk"];
      };
    };
  };
}
