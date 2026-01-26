{
  pkgs-unstable,
  config,
  lib,
  pkgs,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.darktable;
  darktable = cfg.package;

in

{
  options.extra.darktable = with lib; {
    enable = mkEnableOption "darkatble";
    package = mkPackageOption pkgs-unstable "darktable" { pkgsText = "pkgs-unstable"; };

    full = mkOption {
      type = types.bool;
      default = false;
      description = "extra packages related to darktable";

    };

    library = mkOption {
      type = types.path;
      default = "${config.xdg.configHome}/darktable/library.db";
      description = "location of the `library.db` database";
    };

    export = {
      name = mkOption {
        type = types.str;
        default = "generate-jpgs";
        description = "name of the service";
      };
      jpgsDir = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "location of the jpegs";
      };
      quality = mkOption {
        type = types.int;
        default = 80;
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = { };
      };
      extraServiceConfig = mkOption {
        type = types.attrs;
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        extra = with pkgs; [
          xpano
          rapid-photo-downloader
          hugin
        ];
      in
      [
        darktable
      ]
      ++ (if cfg.full then extra else [ ]);

    systemd.user =
      let
        script-config =
          with cfg.export;
          {
            inherit quality;
            dry_run = false;
            library = cfg.library;
            stateless = true;
            jpgs = jpgsDir;
          }
          // extraConfig;

        gen-config = pkgs.writeText "config.json" (builtins.toJSON script-config);
        service-exists = cfg.export.jpgsDir != null;
        generate-jpgs = pkgs-self.darktable-jpeg-sync;
        name = cfg.export.name;
      in
      lib.mkIf service-exists {
        services."${name}" = {

          Unit.Description = "Service to generate JPGs";
          Service = {
            ExecStart = "${generate-jpgs}/bin/generate-jpegs -c ${gen-config}  --darktable-cli-path ${darktable}/bin/darktable-cli"; # Make sure 'yourPackage' provides 'generate-jpgs'
            # BindPaths = lib.concatStringsSep " " [
            #   "${cfg.locations.originals}:/Volumes/Zeno/media/photos"
            #   "${cfg.locations.export}:${jpgsDir}"
            #   "${generate-jpgs}:${generate-jpgs}"
            # ];
          }
          // cfg.export.extraServiceConfig;
          Install.WantedBy = [ ]; # Optional: ensure the service can be started manually
        };
      };
  };
}
