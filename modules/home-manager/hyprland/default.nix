{
  config,
  pkgs,
  lib,
  ...
}@attrs:
let
  cfg = config.extra.hyprland;
in
{
  imports = [
    ./options.nix
    ./waybar
  ];
  config = lib.mkIf cfg.enable {
    # imports = [ ./wallpapers.nix ];

    home.packages = with pkgs; [
      wofi
      xdg-desktop-portal-hyprland
    ];

    home.file.".config/wofi.css".source = ./wofi.css;

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      # enableNvidiaPatches = true;

      plugins = with pkgs.hyprlandPlugins; [
        # hy3
        # see https://github.com/NixOS/nixpkgs/issues/366182
        # hypr-dynamic-cursors
        # hyprtrails
      ];

      settings = (import ./settings.nix (attrs // { i3 = false; })) // cfg.extraSettings;
      # extraConfig = ''
      #   input.kb_file = ${./layout.xkb};
      # '';
    };
  };
}
