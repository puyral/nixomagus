{
  config,
  lib,
  pkgs,
  computer,
  ...
}:
let
  cfg = config.extra.ntfy-client;

  ntfy-done = pkgs.callPackage ./ntfy-done.nix {topic=cfg.topic;};
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
  };
}
