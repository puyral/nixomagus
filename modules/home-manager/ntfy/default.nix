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
    topic = lib.mkOption {
      type = lib.types.str;
      default = "simon";
      description = "Default topic to publish to";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ntfy-sh ];

    sops.secrets.ntfy_token = {
      sopsFile = ../../../users/simon/secrets-sops/ntfy.yaml;
      format = "yaml";
    };

    # Use the host SSH key for decryption (requires read access for the user)
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.templates."client.yml" = {
      content = ''
        default-host: ${cfg.url}
        default-access-token: ${config.sops.placeholder.ntfy_token}
      '';
      path = "${config.xdg.configHome}/ntfy/client.yml";
    };

    programs.zsh.shellAliases = {
      notify = "ntfy publish ${cfg.topic}";
    };
  };
}
