{
  pkgs,
  config,
  lib,
  computer,
  ...
}:

let
  inherit (cfg) resolution;
  cfg = config.extra.remoteDarktable;
  darktable = lib.getExe pkgs.darktable;
  wayvnc = lib.getExe pkgs.wayvnc;
  sway = lib.getExe pkgs.sway;
  swaymsg = lib.getExe' pkgs.sway "swaymsg";
  tip = config.ips."${computer.name}";
  port = builtins.toString cfg.port;
  swConfig = pkgs.writeText "sway-wayvnc.conf" ''
    output HEADLESS-1 resolution ${resolution}

    # Disable Xwayland since darktable and wayvnc run natively on Wayland
    xwayland disable

    # Make darktable fill the screen cleanly without window borders
    default_border none

    exec ${wayvnc} --gpu ${tip} ${port}
    exec "${darktable}; ${swaymsg} exit"
  '';
  remote-studio = pkgs.writeShellScriptBin "remote-studio" ''
    export WLR_BACKENDS=headless
    export WLR_LIBINPUT_NO_DEVICES=1

    exec ${sway} --config ${swConfig}
  '';

in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    # Ensure user can access the GPU render node (for Darktable OpenCL and
    # headless wlroots rendering) while GDM holds the physical seat
    users.users.simon.extraGroups = [
      "video"
      "render"
    ];

    environment.systemPackages = [
      remote-studio
    ];
  };
}
