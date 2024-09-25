{
  config,
  lib,
  pkgs,
  custom,
  ...
}:

with lib;
let
  cfg = config.services.isw;
  defaultConf = "${custom.isw}/etc/isw.conf";
in
{
  options = {
    services.isw = {
      enable = mkEnableOption "msi laptop fan profile daemon";

      configFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          The path to the <filename>isw.conf</filename> file. Leave
          to null to use the default config file included in the package
        '';
      };
    };
  };

  config = {
    environment.systemPackages = mkIf cfg.enable [ custom.isw ];

    environment.etc."isw.conf".source = mkIf cfg.enable (
      if cfg.configFile == null then defaultConf else cfg.configFile
    );

    boot.kernelModules = mkIf cfg.enable [ "ec_sys" ];
    boot.extraModprobeConfig = mkIf cfg.enable "options ec_sys write_support=1";

    systemd = {
      packages = [ custom.isw ];
      services.isw = {
        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
