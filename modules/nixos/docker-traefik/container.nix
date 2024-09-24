{ config, lib, ... }:
with builtins lib;
let

  defaultBackend = options.virtualisation.oci-containers.backend.default;
  containerOptions =
    { ... }:
    {
      options = {

        image = mkOption {
          type = with types; str;
          description = "OCI image to run.";
          example = "library/hello-world";
        };

        imageFile = mkOption {
          type = with types; nullOr package;
          default = null;
          description = ''
            Path to an image file to load before running the image. This can
            be used to bypass pulling the image from the registry.

            The `image` attribute must match the name and
            tag of the image contained in this file, as they will be used to
            run the container with that image. If they do not match, the
            image will be pulled from the registry as usual.
          '';
          example = literalExpression "pkgs.dockerTools.buildImage {...};";
        };

        login = {

          username = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "Username for login.";
          };

          passwordFile = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "Path to file containing password.";
            example = "/etc/nixos/dockerhub-password.txt";
          };

          registry = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "Registry where to login to.";
            example = "https://docker.pkg.github.com";
          };

        };

        cmd = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = "Commandline arguments to pass to the image's entrypoint.";
          example = literalExpression ''
            ["--port=9000"]
          '';
        };

        labels = mkOption {
          type = with types; attrsOf str;
          default = { };
          description = "Labels to attach to the container at runtime.";
          example = literalExpression ''
            {
              "traefik.https.routers.example.rule" = "Host(`example.container`)";
            }
          '';
        };

        entrypoint = mkOption {
          type = with types; nullOr str;
          description = "Override the default entrypoint of the image.";
          default = null;
          example = "/bin/my-app";
        };

        environment = mkOption {
          type = with types; attrsOf str;
          default = { };
          description = "Environment variables to set for this container.";
          example = literalExpression ''
            {
              DATABASE_HOST = "db.example.com";
              DATABASE_PORT = "3306";
            }
          '';
        };

        environmentFiles = mkOption {
          type = with types; listOf path;
          default = [ ];
          description = "Environment files for this container.";
          example = literalExpression ''
            [
              /path/to/.env
              /path/to/.env.secret
            ]
          '';
        };

        log-driver = mkOption {
          type = types.str;
          default = "journald";
          description = ''
            Logging driver for the container.  The default of
            `"journald"` means that the container's logs will be
            handled as part of the systemd unit.

            For more details and a full list of logging drivers, refer to respective backends documentation.

            For Docker:
            [Docker engine documentation](https://docs.docker.com/engine/reference/run/#logging-drivers---log-driver)

            For Podman:
            Refer to the docker-run(1) man page.
          '';
        };

        ports = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = ''
            Network ports to publish from the container to the outer host.

            Valid formats:
            - `<ip>:<hostPort>:<containerPort>`
            - `<ip>::<containerPort>`
            - `<hostPort>:<containerPort>`
            - `<containerPort>`

            Both `hostPort` and `containerPort` can be specified as a range of
            ports.  When specifying ranges for both, the number of container
            ports in the range must match the number of host ports in the
            range.  Example: `1234-1236:1234-1236/tcp`

            When specifying a range for `hostPort` only, the `containerPort`
            must *not* be a range.  In this case, the container port is published
            somewhere within the specified `hostPort` range.
            Example: `1234-1236:1234/tcp`

            Refer to the
            [Docker engine documentation](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) for full details.
          '';
          example = literalExpression ''
            [
              "8080:9000"
            ]
          '';
        };

        user = mkOption {
          type = with types; nullOr str;
          default = null;
          description = ''
            Override the username or UID (and optionally groupname or GID) used
            in the container.
          '';
          example = "nobody:nogroup";
        };

        volumes = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = ''
            List of volumes to attach to this container.

            Note that this is a list of `"src:dst"` strings to
            allow for `src` to refer to `/nix/store` paths, which
            would be difficult with an attribute set.  There are
            also a variety of mount options available as a third
            field; please refer to the
            [docker engine documentation](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems) for details.
          '';
          example = literalExpression ''
            [
              "volume_name:/path/inside/container"
              "/path/on/host:/path/inside/container"
            ]
          '';
        };

        workdir = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Override the default working directory for the container.";
          example = "/var/lib/hello_world";
        };

        dependsOn = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = ''
            Define which other containers this one depends on. They will be added to both After and Requires for the unit.

            Use the same name as the attribute under `virtualisation.oci-containers.containers`.
          '';
          example = literalExpression ''
            virtualisation.oci-containers.containers = {
              node1 = {};
              node2 = {
                dependsOn = [ "node1" ];
              }
            }
          '';
        };

        hostname = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "The hostname of the container.";
          example = "hello-world";
        };

        extraOptions = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = "Extra options for {command}`${defaultBackend} run`.";
          example = literalExpression ''
            ["--network=host"]
          '';
        };

        autoStart = mkOption {
          type = types.bool;
          default = true;
          description = ''
            When enabled, the container is automatically started on boot.
            If this option is set to false, the container has to be started on-demand via its service.
          '';
        };

        proxy = {
          port = mkOption {
            type = types.nullOr types.port;
            default = null;
          };
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      };
    };

  cfg = {
    traefik = config.networking.traefik.docker;
    container = name: options.virtualisation.proxied-oci-containers.containers.${name}.proxy;
  };

  enabled = config.network.traefik.enable && config.network.traefik.docker.enable;
  containers = config.virtualisation.proxied-oci-containers.containers;
in
{
  options.virtualisation.proxied-oci-containers.containers = mkOption {
    default = { };
    type = types.attrsOf (types.submodule containerOptions);
    description = "OCI (Docker) containers to run as systemd services.";
  };
  config.virtualisation.oci-containers.containers =
    let
      f =
        n: value:
        let
          nvalue = removeAttrs "proxy" value;
          proxy = cfg.container n;
          name = proxy.name;
          port = proxy.port;

          labels = mkIf enabled {
            "traefik.enable" = "true";
            "traefik.http.routers.${name}.rule" = "Host(`${name}.${config.network.traefik.baseDomain}`)";
            "traefik.http.routers.${name}.entrypoints" = "https";
            "traefik.http.routers.${name}.tls.certresolver" = "ovh";
            "traefik.http.services.${name}.loadbalancer.server." = toString port;
          };
        in
        recursiveUpdate nvalue { inherit labels; };
    in
    mapAttrs f containers;

  config.systemd.services = mkIf enabled (
    mapAttrs' (n: v: {
      name = "${config.virtualisation.oci-containers.backend}-${n}";
      value = {
        after = [ "${cfg.traefik.serviceName}.service" ];
        requires = [ "${cfg.traefik.serviceName}.service" ];
        wantedBy = [ "multi-user.target" ];
      };
    }) containers
  );

}
