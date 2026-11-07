{
  config,
  lib,
  ...
}:
let
  cfg = config.extra.grafanactl;
in
{
  options.extra.grafanactl = with lib; {
    enable = mkEnableOption "grafanactl";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.grafanactl_user = {
      sopsFile = ./credentials.sops-secret.yaml;
      key = "user";
    };
    sops.secrets.grafanactl_password = {
      sopsFile = ./credentials.sops-secret.yaml;
      key = "password";
    };
    sops.templates."grafanactl-config.yaml" = {
      path = "${config.xdg.configHome}/grafanactl/config.yaml";
      content = ''
        contexts:
          default:
            grafana:
              server: https://grafana.puyral.fr
              org-id: 1
              user: ${config.sops.placeholder.grafanactl_user}
              password: ${config.sops.placeholder.grafanactl_password}
        current-context: default
      '';
    };
  };
}
