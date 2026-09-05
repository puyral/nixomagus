{
  lib,
  config,
  ...
}:
let
  cfg = config.extra.forgejo-runners;
  name = "forgejo-runners";
  enabled = lib.filterAttrs (_: r: r.enable) cfg.runners;
  enable = cfg.enable && enabled != { };
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf enable {
    containers.${name} = {
      autoStart = true;
      ephemeral = true;

      bindMounts = {
        # Bind only the host SSH key. sops-nix runs *inside* the container and
        # decrypts the runner tokens there, so no decrypted secrets ever touch
        # the host filesystem or the container's bind mounts.
        "/etc/sops" = {
          hostPath = cfg.sopsKey;
          isReadOnly = true;
        };
      };

      config =
        { config, ... }:
        {
          # sops-nix is already imported into every container via `eimports`.
          # Point it at the bound host key so it can decrypt the runner tokens.
          sops.age.sshKeyPaths = [ "/etc/sops" ];

          sops.secrets = lib.mapAttrs' (rname: r: {
            name = "forgejo-runner/${rname}";
            value = {
              sopsFile = r.tokenFile;
              format = "dotenv";
              key = "TOKEN";
            };
          }) enabled;

          services.gitea-actions-runner = {
            package = cfg.package;
            instances = lib.mapAttrs (rname: r: {
              enable = true;
              name = rname;
              url = r.url;
              labels = r.labels;
              hostPackages = r.hostPackages;
              settings = r.settings;
              tokenFile = config.sops.secrets."forgejo-runner/${rname}".path;
            }) enabled;
          };
        };
    };

    extra.containers.${name} = {
      privateNetwork = false;
    };
  };
}
