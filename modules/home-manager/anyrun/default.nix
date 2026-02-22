{ config, lib, ... }:
let
  cfg = config.extra.anyrun;
  pkg = config.programs.anyrun.package;
  mkPlugin = p: "${pkg}/lib/lib${p}.so";
  mkPlugins = lib.map mkPlugin;
in
{
  options.extra.anyrun = {
    enable = lib.mkEnableOption "anyrun";
  };
  config = lib.mkIf cfg.enable {
    programs.anyrun = {
      enable = true;
      config = {
        closeOnClick = true;
        hidePluginInfo = true;
        x = {
          fraction = 0.5;
        };
        y = {
          fraction = 0.3;
        };
        width = {
          fraction = 0.3;
        };
        hideIcons = false;

        plugins = (
          mkPlugins [
            "applications"
            "nix_run"
            "rink"
            "shell"
          ]
        );
      };
      extraConfigFiles = {
        "nix-run.ron".text = ''
          '
          // <Anyrun config dir>/nix-run.ron
          Config(
            prefix: ":nr ",
            // Whether or not to allow unfree packages
            allow_unfree: false,
            // Nixpkgs channel to get the package list from
            channel: "nixpkgs-unstable",
            max_entries: 3,
          )
        '';
      };
    };
  };
}
