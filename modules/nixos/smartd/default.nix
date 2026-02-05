{
  config,
  lib,
  rootDir,
  ...
}:
let
  cfg = config.extra.smartd;
  enabled = cfg.enable && (cfg.disks != [ ]);
in
{
  options.extra.smartd = with lib; {
    enable = mkEnableOption "S.M.A.R.T. deamon";
    disks = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of disk ids";
    };
  };

  config.services.smartd = lib.mkIf enabled {
    enable = true;
    defaults = {
      monitored = "-a -o on -s (S/../.././02|L/../../1/02)";
    };
    devices =
      let
        Disk = id: { device = "/dev/disk/by-id/${id}"; };
        Disks = cfg.disks;
      in
      builtins.map Disk Disks ++ [ ];

    notifications = {
      test = true;
      mail = {
        sender = config.programs.msmtp.accounts.default.from;
        recipient = "admin@puyral.fr";
      };
    };
  };
}
