{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.ntfy-client;

  ntfy-done = pkgs.callPackage ./ntfy-done.nix { topic = cfg.topic; };
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
  };
}
