{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.extra.wandarr;
  configFile = pkgs.writeText "wandarr.yml" (builtins.toJSON cfg.settings);
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {

    systemd.user.services.wandarr = {
      Unit.Description = "Wandarr Transcoding Service";
      Install.WantedBy = [ "multi-user.target" ];
      Install.After = [ "network.target" ];

      Service = {
        # -y specifies the config file
        ExecStart = "${cfg.package}/bin/wandarr -y ${configFile}";
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";

        ProtectSystem = "full";
        PrivateTmp = true;
      };
    };
  };

}
