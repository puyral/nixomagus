{
  mconfig,
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.sway;
in
{
  config = mkIf cfg.enable {
    vars.swayBarStatusCommand = "${config.programs.i3status-rust.package}/bin/i3status-rs ${./bar.toml}";

    home.packages = with pkgs; [
      i3status-rust
      pavucontrol
    ];
  };
}
