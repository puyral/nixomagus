{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.gitConfigFetcher;
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
      Unit.Description = "Get config fetcher";
      Service = {
        Type = "oneshot";
        WorkingDirectory = cfg.location;
        ExecStart = "${pkgs.git}/bin/git fetch";
      };
    };

    timers.${name} = {
      Unit.Description = "Run Get config fetcher";
      Install.WantedBy = [ "timers.target" ];
      # PartOf = [ "git-fetch-config.service" ];
      Timer = {
        OnCalendar = cfg.timer; # Run every 10 minutes
        Unit = "${name}.service";
      };
    };
  };
}
