{ lib, pkgs-self, ... }:
{
  options.extra.wandarr = with lib; {
    enable = mkEnableOption "wandarr service";

    package = mkOption {
      type = types.package;
      default = pkgs-self.wandarr;
      description = "The wandarr package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "wandarr";
      description = "User account under which wandarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "wandarr";
      description = "Group under which wandarr runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/wandarr";
      description = "Working directory for the service.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Configuration for wandarr.yml. 
        Example:
        {
          cluster = { ... };
          engines = { ... };
        }
      '';
    };

    client = {
      enable = mkEnableOption "wandarr client";
      settings = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Configuration for wandarr.yml. 
          Example:
          os = "linux";
            type = "local";
            working_dir = "/tmp";
            ffmpeg = "${pkgs.ffmpeg}/bin/ffmpeg"; # You can reference nix packages here!
            engines = [
              { name = "cpu"; status = "enabled"; }
            ];
        '';
      };

    };
  };
}
