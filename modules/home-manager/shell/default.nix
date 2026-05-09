{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.extra.shell;
  jailed = config.extra.jail.enable;
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
        type = types.enum [
          "nixos"
          "home-manager"
        ];
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
    extra.starship.enable = true;

    home.packages = [ rebuildPackage ];

    programs.nix-index = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
      tmux = lib.mkIf config.extra.tmux.enable {
        enableShellIntegration = true;
      };
    };

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    programs.nix-index-database.comma.enable = true;

    extra.gitConfigFetcher.enable = !jailed;

    home.sessionVariables = {
      CONFIG_LOCATION = config.extra.nix.configDir;
    };
  };
}
