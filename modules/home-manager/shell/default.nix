{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.shell;
  rebuildPackage = pkgs.callPackage ../../../packages/rebuild {
    rebuildCmd = cfg.rebuild.command;
    flakePath = cfg.rebuild.flakePath;
  };
in
{
  options.extra.shell = {
    enable = mkEnableOption "custom shell";
    rebuild = {
      command = mkOption {
        type = types.str;
        default = "sudo nixos-rebuild switch --flake '${config.extra.nix.configDir}'";
        description = "Command to execute for rebuilding the system.";
      };
      flakePath = mkOption {
        type = types.str;
        default = config.extra.nix.configDir;
        description = "Path to the configuration flake.";
      };
    };
  };
  config = mkIf cfg.enable {
    # extra.zsh.enable = true;
    extra.starship.enable = true;

    home.packages = [ rebuildPackage ];

    home.shellAliases = {
      # "update" = "nix flake update /config#";
      # "start-camera" = "" + ./scripts/start-camera.sh;
      # "uro" = "bash ${./scripts/update-upgrade-optimize.sh}";
    };
  };

  # home.file.".cache/scipts/start-camera".source = ./scripts/start-camera.sh;
}
