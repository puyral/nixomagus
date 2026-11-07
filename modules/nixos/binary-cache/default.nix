{ config, lib, ... }:
let
  cfg = config.extra.cache;
  cname = "binary-cache";
  port = cfg.port;

in

{
  imports = [
    ./options.nix
    ./substituter.nix
  ];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.substituter;
        message = "you can be substituter on your own machine";
      }
    ];
    containers.${cname} = {
      autoStart = true;
      ephemeral = true;
      bindMounts = {
        # Host ssh key, used by sops-nix inside the container to decrypt secrets
        "/etc/sops" = {
          hostPath = "/etc/ssh/ssh_host_ed25519_key";
          isReadOnly = true;
        };
      };
      config =
        { config, ... }:
        {
          # sops inside the container, decrypting with the host ssh key mounted at /etc/sops
          sops.age.sshKeyPaths = [ "/etc/sops" ];
          sops.secrets.binary_cache_key = {
            sopsFile = ./secret-key.sops-secret.yaml;
            key = "key";
          };

          services.nix-serve = {
            inherit port;
            enable = true;
            secretKeyFile = config.sops.secrets.binary_cache_key.path;
            openFirewall = true;
          };
        };
    };

    extra.containers.${cname} = {
      nginx = [
        {
          inherit port;
          enable = true;
          name = "nix.dynas";
        }
      ];
    };
  };
}
