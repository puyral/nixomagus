{ config, pkgs, ... }:
{
    imports = [];
    wayland.windowManager.hyprland = {
        enable = true;
        # enableNvidiaPatches = true;


        settings = {
            "$mod" = "SUPER";
            bind = [
                "$mod, Q, exec, allacrity"
                ", Home, exec, allacrity"
                "$mod, E, "
            ];
        };
    };
}
