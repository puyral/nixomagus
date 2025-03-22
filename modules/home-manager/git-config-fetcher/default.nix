{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.extra.gitConfigFetcher;
  user = config.extra.user.name;
  name = "git-fetch-config";
in
{
  options.extra.gitConfigFetcher = with lib; {
    enable = mkEnableOption "auto git fetcher for config";
    location = mkOption {
      type = types.path;
      default = "/config";
    };
    timer = mkOption {
      type = types.str;
      default = "*-*-* *:0/10:0";
    };
  };
  config.systemd.user = lib.mkIf cfg.enable {
    services.${name} = {
      Unit.Description = "Git fetch config every 10 minutes";
      # wantedBy = [ "timers.target" ];
      Service = {
        Type = "oneshot";
        WorkingDirectory = cfg.location;
        User = user; # Replace with your actual username if different
        ExecStart = "${pkgs.git}/bin/git fetch";
      };
    };

    timers.${name} = {
      Unit.Description = "Run git fetch config every 10 minutes";
      Install.WantedBy = [ "timers.target" ];
      # PartOf = [ "git-fetch-config.service" ];
      Timer = {
        OnCalendar = cfg.timer; # Run every 10 minutes
        Unit = "${name}.service";
      };
    };
  };
}
