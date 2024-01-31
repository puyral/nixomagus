{ config, pkgs, ... }:
{
  imports = [ ./wallpapers.nix ];

  home.packages = with pkgs; [
    wofi
  ];

  home.file."config/wofi.css".source = ./wofi.css;

  wayland.windowManager.hyprland = {
    enable = true;
    # enableNvidiaPatches = true;


    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, Q, exec, allacrity"
        ", Home, exec, allacrity"
        "$mod,R,exec,wofi --show run --xoffset=1670 --yoffset=12 --width=230px --height=984 --style=$HOME/.config/wofi.css --term=footclient --prompt=Run"
      ]

      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList
          (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                builtins.toString (x + 1 - (c * 10));
            in
            [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          )
          10)
      );
    };

    xwayland.enable = true;

    general = {
      sensitivity = 1;
      main_mod = "SUPER";

      gaps_in = 6;
      gaps_out = 12;
      border_size = 4;
      col = {
        active_border = "0xffb072d1";
        inactive_border = "0xff292a37";
      };

      damage_tracking = "full";
    };
  };
}
