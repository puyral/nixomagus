{
  config,
  lib,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.music-assistant;
  # Container name must keep "ve-${name}" under 16 chars (Linux IFNAMSIZ limit)
  name = "mass";
  uiPort = 8095;
  stateDir = "/var/lib/music-assistant";
  useYTMusic = lib.elem "ytmusic" cfg.providers;

  # Internal ports used by Music Assistant and its built-in Snapserver
  internalPorts = {
    stream = 8097;
    snapcastStream = 1704;
    snapcastControl = 1705;
    snapcastHttp = 1780;
  };

  forwardedTcpPorts = [
    {
      hostPort = cfg.ports.stream;
      containerPort = internalPorts.stream;
    }
  ]
  ++ lib.optionals cfg.snapcast.enableBuiltinServer [
    {
      hostPort = cfg.ports.snapcastStream;
      containerPort = internalPorts.snapcastStream;
    }
    {
      hostPort = cfg.ports.snapcastControl;
      containerPort = internalPorts.snapcastControl;
    }
    {
      hostPort = cfg.ports.snapcastHttp;
      containerPort = internalPorts.snapcastHttp;
    }
  ]
  ++ cfg.ports.extraTcpForwards;

  snapserverSources =
    if cfg.snapcast.sources != [ ] then
      cfg.snapcast.sources
    else
      [ "pipe:///tmp/snapfifo?name=default" ];

  snapserverConf = ''
    [stream]
    ${lib.concatMapStringsSep "\n" (src: "source = ${src}") snapserverSources}
    ${cfg.snapcast.extraConfig}
  '';
in
{
  imports = [
    ./options.nix
    ./bluetooth.nix
  ];

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
      map (p: p.hostPort) forwardedTcpPorts
    );

    containers.${name} = {
      autoStart = true;
      ephemeral = true;

      forwardPorts = map (p: {
        protocol = "tcp";
        inherit (p) hostPort containerPort;
      }) forwardedTcpPorts;

      bindMounts = {
        "${stateDir}" = {
          hostPath = cfg.dataDir;
          isReadOnly = false;
        };
      }
      // lib.optionalAttrs (cfg.musicDir != null) {
        "/music" = {
          hostPath = cfg.musicDir;
          isReadOnly = true;
        };
      }
      // cfg.snapcast.extraBindMounts;

      config =
        { pkgs, lib, ... }:
        {
          services.music-assistant = {
            enable = true;
            openFirewall = cfg.openFirewall;
            providers = cfg.providers;
          };

          networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
            map (p: p.containerPort) forwardedTcpPorts
          );

          environment.etc."snapserver.conf" = lib.mkIf cfg.snapcast.enableBuiltinServer {
            text = snapserverConf;
          };

          users.users.music-assistant = {
            isSystemUser = true;
            group = "music-assistant";
            home = stateDir;
          };
          users.groups.music-assistant = { };

          systemd.services.bgutil-pot-server = lib.mkIf useYTMusic {
            description = "BgUtils YouTube PO Token Server for yt-dlp";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            before = [ "music-assistant.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              ExecStart = "${lib.getExe pkgs-self.bgutil-ytdlp-pot-provider-server} --port 4416";
              DynamicUser = true;
              Restart = "on-failure";
            };
          };

          systemd.services.music-assistant = {
            after = lib.optional useYTMusic "bgutil-pot-server.service";
            wants = lib.optional useYTMusic "bgutil-pot-server.service";
            serviceConfig = {
              # Disable DynamicUser so systemd does not attempt to replace the
              # bind-mounted /var/lib/music-assistant with a /var/lib/private symlink
              # or assign a new transient UID on each ephemeral container boot.
              DynamicUser = lib.mkForce false;
              User = "music-assistant";
              Group = "music-assistant";
              ExecStartPre = [
                "+${pkgs.coreutils}/bin/chown -R music-assistant:music-assistant ${stateDir}"
              ];
            };
          };
        };
    };

    extra.containers.${name} = {
      nginx = [
        {
          port = uiPort;
          name = cfg.subdomain;
          enable = true;
          providers = cfg.nginxProviders;
        }
      ]
      ++ lib.optionals (cfg.snapcast.enableBuiltinServer && cfg.snapcast.subdomain != null) [
        {
          port = internalPorts.snapcastHttp;
          name = cfg.snapcast.subdomain;
          enable = true;
          providers = cfg.nginxProviders;
        }
      ];
    };
  };
}
