{
  mconfig,
  config,
  pkgs,
  ...
}:
let
  vars = {
    z2m_port = 8080;
    ha_base_dir = "/containers/homeassistant";
    z2m_base_dir = "/containers/zigbee2mqtt";
    name = "ha";
    usb_donlge = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c969fdb7c12ec119aa120c7bd930c07-if00-port0";
  };
  enabled = true;
in
with vars;
{config = if enabled then {
  networking.nat.internalInterfaces = [ "ve-${name}" ];
  # because "homeassistant" is too long...
  containers.${name} = {
    bindMounts = {
      "/data/ha" = {
        hostPath = "${ha_base_dir}";
        isReadOnly = false;
      };
      "/data/z2m" = {
        hostPath = "${z2m_base_dir}";
        isReadOnly = false;
      };
      "/dev/ttyUSB1" = {
        hostPath = usb_donlge;
        isReadOnly = false;
      };
    };

    allowedDevices = [
      {
        modifier = "rw";
        node = usb_donlge;
      }
    ];

    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "192.168.1.2";
    localAddress = "192.168.100.11";

    config =
      { lib, ... }:
      {
        imports = [
          ((import ./homeassistant.nix) config vars)
          ((import ./z2m.nix) config vars)
        ];

        system.stateVersion = mconfig.nixos;
        networking = {
          firewall.enable = true;
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };
        programs.nix-ld.enable = true;
        services.resolved.enable = true;
        # users.users.simon = config.users.users.simon;
        # users.mutableUsers = false;
        # security.sudo.wheelNeedsPassword = false;
        # programs.zsh.enable = true;
      };
  };
  services.traefik.dynamicConfigOptions.http =
    let
      mkConfig = name: port: {
        routers.${name} = {
          rule = "Host(`${name}.puyral.fr`)";
          entrypoints = "https";
          tls.certResolver = "ovh";
          service = name;
        };
        services.${name} = {
          loadBalancer.servers = [ { url = "http://${config.containers.ha.localAddress}:${builtins.toString port}"; } ];
        };
      };
    in
    pkgs.lib.attrsets.recursiveUpdate (mkConfig "homeassistant" 8123) (mkConfig "zigbee2mqtt" z2m_port);

} else {};}
