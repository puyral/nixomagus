{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.direnv;
in
{
  options.extra.direnv = with lib; {
    enable = mkEnableOption "direnv";
    gc = {
      enable = mkEnableOption "garbage collections" // {
        default = true;
      };
      timer = mkOption {
        default = "weekly";
        type = types.str;
      };
      olderThan = mkOption {
        default = "14";
        type = types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;

      # from https://github.com/direnv/direnv/wiki/Customizing-cache-location#human-readable-directories
      stdlib = builtins.readFile ./stdlib;
    };

    systemd.user.services.direnv-gc = lib.mkIf cfg.gc.enable {
      Unit.Description = "Garbage collect centralized direnv layouts";
      Service = {
        Type = "oneshot";
        # %h is the systemd variable for the user's home directory
        ExecStart = "find %h/.cache/direnv/layouts -type d -atime +${cfg.gc.olderThan} -prune -exec rm -rf {} +";
      };
    };

    systemd.user.timers.direnv-gc = {
      Unit.Description = "Weekly timer for direnv garbage collection";
      Timer = {
        OnCalendar = cfg.gc.timer;
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
