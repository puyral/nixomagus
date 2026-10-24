{ lib, config, ... }:
with lib;
{
  options.extra.music-assistant = {
    enable = mkEnableOption "Music Assistant";

    dataDir = mkOption {
      type = types.path;
      default = "${config.params.locations.containers}/music-assistant";
      description = "Folder on the host to persist Music Assistant state (/var/lib/music-assistant).";
    };

    musicDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Optional local music folder to bind-mount into the container at /music.";
    };

    subdomain = mkOption {
      type = types.str;
      default = "music";
      description = "Subdomain to expose the Music Assistant web UI on.";
    };

    providers = mkOption {
      type = types.listOf types.str;
      default = [
        "ytmusic"
        "snapcast"
      ];
      description = "Music Assistant providers to enable.";
    };

    nginxProviders = mkOption {
      type = types.listOf types.str;
      default = [ "dynas" ];
      description = "Machines that should reverse-proxy this service.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the forwarded ports in the host firewall.";
    };

    ports = {
      stream = mkOption {
        type = types.port;
        default = 8097;
        description = "Host TCP port forwarded to Music Assistant's stream server (container port 8097).";
      };

      snapcastStream = mkOption {
        type = types.port;
        default = 1704;
        description = "Host TCP port forwarded to the built-in Snapserver audio stream port (container port 1704).";
      };

      snapcastControl = mkOption {
        type = types.port;
        default = 1705;
        description = "Host TCP port forwarded to the built-in Snapserver JSON-RPC control port (container port 1705).";
      };

      snapcastHttp = mkOption {
        type = types.port;
        default = 1780;
        description = "Host TCP port forwarded to the built-in Snapserver HTTP/Snapweb port (container port 1780).";
      };

      extraTcpForwards = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              hostPort = mkOption {
                type = types.port;
                description = "Port on the host.";
              };
              containerPort = mkOption {
                type = types.port;
                description = "Port inside the container.";
              };
            };
          }
        );
        default = [ ];
        example = [
          {
            hostPort = 4953;
            containerPort = 4953;
          }
        ];
        description = "Additional TCP ports to forward from the host into the container (e.g. for TCP audio input sources).";
      };
    };

    snapcast = {
      enableBuiltinServer = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to expose ports and generate /etc/snapserver.conf for Music Assistant's built-in Snapcast server.";
      };

      bluetoothSink = {
        enable = mkEnableOption "host Bluetooth A2DP sink routed to the built-in Snapcast server";

        name = mkOption {
          type = types.str;
          default = config.networking.hostName;
          description = "Bluetooth speaker name advertised by the host.";
        };
      };

      subdomain = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "snapcast";
        description = "Optional subdomain to expose the built-in Snapweb HTTP UI (port 1780) via nginx.";
      };

      sources = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "pipe:///tmp/snapfifo?name=default"
          "tcp://0.0.0.0:4953?name=Bluetooth&mode=server"
        ];
        description = ''
          List of Snapcast stream source URIs written to `[stream]` in `/etc/snapserver.conf`
          inside the container. Music Assistant dynamically adds its own playback streams
          alongside these and falls back to the stream named `default` when idle.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra configuration lines appended to `/etc/snapserver.conf` inside the container.";
      };

      extraBindMounts = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              hostPath = mkOption { type = types.str; };
              isReadOnly = mkOption {
                type = types.bool;
                default = false;
              };
            };
          }
        );
        default = { };
        description = "Additional bind mounts into the container (e.g. for sharing a Bluetooth FIFO pipe directory from the host).";
      };
    };
  };
}
