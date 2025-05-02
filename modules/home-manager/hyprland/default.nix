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

      settings = (import ./settings.nix attrs) // cfg.extraSettings;
      # extraConfig = ''
      #   input.kb_file = ${./layout.xkb};
      # '';
    };
  };
}
