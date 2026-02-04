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
    flakePath = cfg.rebuild.flakePath;
    type = cfg.rebuild.type;
    name = cfg.rebuild.name;
  };
in
{
  options.extra.shell = {
    enable = mkEnableOption "custom shell";
    rebuild = {
      type = mkOption {
        type = types.enum [ "nixos" "home-manager" ];
        default = "nixos";
        description = "Type of system to rebuild (nixos or home-manager).";
      };
      name = mkOption {
        type = types.str;
        default = "simon";
        description = "Username for remote builds.";
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
