{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.grafanactl;
  yamlFormat = pkgs.formats.yaml { };
in
{
  options.extra.grafanactl = with lib; {
    enable = mkEnableOption "grafanactl";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [ grafanactl ];
      file."${config.xdg.configHome}/grafanactl/config.yaml" = {
        source = yamlFormat.generate "config.yaml" {
          contexts = {
            default = {
              grafana = {
                server = "https://grafana.puyral.fr";
                org-id = 1;
              }
              // (import ./secrets/credentials.nix);
            };
          };
          current-context = "default";
        };
      };
    };

  };
}
