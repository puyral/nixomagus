{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extra.ntfy-client;
in
{
  options.extra.ntfy-client = {
    enable = lib.mkEnableOption "ntfy client";
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.puyral.fr";
      description = "The ntfy server URL";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ntfy-sh ];

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
  };
}
