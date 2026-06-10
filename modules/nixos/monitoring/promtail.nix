{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.monitoring.promtail;
in
lib.mkIf cfg.enable {
  users.users.alloy = {
    isSystemUser = true;
    group = "alloy";
    extraGroups = [
      "systemd-journal-remote"
      "systemd-journal"
    ];
  };
  users.groups.alloy = { };

  services.alloy = {
    enable = true;
    configPath = pkgs.writeText "config.alloy" ''
      discovery.relabel "journal" {
        targets = []
        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }

      loki.source.journal "read" {
        forward_to    = [loki.write.local.receiver]
        relabel_rules = discovery.relabel.journal.rules
        labels        = {
          job = "systemd-journal"
          host = "${cfg.name}"
        }
      }

      discovery.relabel "remote_journal" {
        targets = []
        rule {
          source_labels = ["__journal__hostname"]
          target_label  = "container"
        }
        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }

      loki.source.journal "remote" {
        path = "/var/log/journal/remote"
        forward_to = [loki.write.local.receiver]
        relabel_rules = discovery.relabel.remote_journal.rules
        labels = { job = "remote-journal" }
      }

      loki.write "local" {
        endpoint {
          url = "http://${cfg.lokiHost}:${builtins.toString cfg.lokiPort}/loki/api/v1/push"
        }
      }
    '';
  };
}
