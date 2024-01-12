{ config, pkgs, ... }:
{
  home-manager.users.simon = {
    home.wayland.windowManager.hyprland = {
        enable = true;
        enableNvidiaPatches = true;
    };
  };
}
