{ lib, config, ... }:
let
  cfg = config.extra.github-runners;
  options = with lib; {
    enable = mkEnableOption "this runner";
    url = mkOption {
      type = types.str;
    };
    tokenFile = mkOption {
      type = types.path;
    };
  };
  enable = cfg.enable && builtins.any (x: x.enable) (builtins.attrValues cfg.runners);
  name = "github-runners";

in
{
  options.extra.github-runners = {
    enable = lib.mkEnableOption "github-runner";
    runners = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          inherit options;
        });
      default = { };
    };
  };
  config = lib.mkIf enable {
    containers.${name} = {
      autoStart = true;
      ephemeral = true;
      config =
        { ... }:
        {
          services.github-runners = cfg.runners;
        };
    };
    extra.containers.${name} = {
      privateNetwork = false;
    };
  };
}
