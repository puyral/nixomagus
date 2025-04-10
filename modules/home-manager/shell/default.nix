{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.shell;
in
{
  options.extra.shell = {
    enable = mkEnableOption "custom shell";
    rebuildScript = mkOption {
      type = types.path;
      default = ./scripts/rebuild.sh;
    };
  };
  config = mkIf cfg.enable {
    # extra.zsh.enable = true;
    extra.starship.enable = true;

    home.shellAliases = {
      "rebuild" = "bash ${cfg.rebuildScript}"; # "time sudo nixos-rebuild switch --flake '/config'"; # ?submodules=1#'";
      # "update" = "nix flake update /config#";
      # "start-camera" = "" + ./scripts/start-camera.sh;
      # "uro" = "bash ${./scripts/update-upgrade-optimize.sh}";
    };
  };

  # home.file.".cache/scipts/start-camera".source = ./scripts/start-camera.sh;
}
