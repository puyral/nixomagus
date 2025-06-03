{ lib, config, ... }:
let
  cfg = config.extra.github-runners;
  options =
    { name, ... }:
    with lib;
    {
      options = {
        enable = mkEnableOption "this runner";
        url = mkOption {
          type = types.str;
        };
        tokenFile = mkOption {
          type = types.path;
        };
        replace = mkOption {
          type = types.bool;
          default = true;
        };
        name = mkOption {
          type = types.str;
          default = name;
        };
        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
        };
      };
    };
  enable = cfg.enable && builtins.any (x: x.enable) (builtins.attrValues cfg.runners);
  name = "github-runners";

in
{
  options.extra.github-runners = {
    enable = lib.mkEnableOption "github-runner";
    runners = lib.mkOption {
      type = with lib.types; attrsOf (submodule options);
      default = { };
    };
  };
  config = lib.mkIf enable {
    containers.${name} =
      let
        mkTokenFile = name: "/run/secrets/github-runner/${name}.token";
        mkBindMounts =
          name:
          { tokenFile, ... }:
          {
            name = mkTokenFile name;
            value = {
              hostPath = tokenFile;
              isReadOnly = true;
            };
          };
        mkRunnerConfig = name: cfg: cfg // { tokenFile = mkTokenFile name; };
      in
      {
        bindMounts = lib.mapAttrs' mkBindMounts cfg.runners;
        autoStart = true;
        ephemeral = false;
        config =
          { ... }:
          {
            services.github-runners = lib.mapAttrs mkRunnerConfig cfg.runners;
          };
      };
    extra.containers.${name} = {
      privateNetwork = false;
    };
  };
}
