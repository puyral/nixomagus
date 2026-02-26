{
  config,
  lib,
  pkgs,
  computer,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.ntfy-client;
  ntfy-done = pkgs-self.ntfy-done.override { topic = cfg.topic; };

  # ntfy-done = pkgs.callPackage ./ntfy-done.nix {topic=cfg.topic;};

  ntfy-forward = pkgs.writeShellApplication {
    name = "ntfy-forward";
    runtimeInputs = with pkgs; [ ntfy-sh jq libnotify ];
    text = ''
      # Forward ntfy notifications to desktop notifications
      # Reads JSON from stdin, sends to notify-send
      
      while read -r line; do
        title=$(echo "$line" | jq -r '.title // ""')
        message=$(echo "$line" | jq -r '.message // ""')
        
        if [ -n "$message" ] && [ "$message" != "null" ]; then
          notify-send -i dialog-information -a ntfy -c "$title" -u normal "$message"
        fi
      done
    '';
  };
in
{
  options.extra.ntfy-client = {
    enable = lib.mkEnableOption "ntfy client";
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.puyral.fr";
      description = "The ntfy server URL";
    };
    topic = lib.mkOption {
      type = lib.types.str;
      default = "cmd";
      description = "Default topic to publish to";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.ntfy-sh
      ntfy-done
    ];

    sops.secrets.ntfy_token = {
      sopsFile = ./ntfy.sops-secret.yaml;
      format = "yaml";
    };

    sops.templates."client.yml" = {
      content = ''
        default-host: ${cfg.url}
        default-token: ${config.sops.placeholder.ntfy_token}
      '';
      path = "${config.xdg.configHome}/ntfy/client.yml";
    };

    programs.zsh.shellAliases = {
      notify = "ntfy-done";
    };

    systemd.user.services.ntfy-startup = {
      Unit = {
        Description = "Notify via ntfy on startup";
        After = [ "network-online.target" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "10s";
        ExecStart = ''
          ${pkgs.ntfy-sh}/bin/ntfy publish \
            --title "System Ready" \
            --tags "rocket" \
            "${computer.name}" \
            "User session started on ${computer.name}"
        '';
      };
    };

    systemd.user.services.ntfy-to-desktop = {
      Unit = {
        Description = "Forward ntfy notifications to desktop";
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = "${pkgs.ntfy-sh}/bin/ntfy sub '${computer.name}' | ${pkgs-self.ntfy-forward}/bin/ntfy-forward";
      };
    };
  };
}
