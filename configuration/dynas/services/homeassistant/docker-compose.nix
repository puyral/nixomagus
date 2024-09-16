# Auto-generated using compose2nix v0.2.2.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    # autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."homeassistant" = {
    image = "homeassistant/home-assistant:latest";
    environment = {
      "TZ" = "Europe/Vienna";
    };
    volumes = [ "/containers/homeassistant:/config:rw" ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.homeassistant.entrypoints" = "https";
      "traefik.http.routers.homeassistant.rule" = "Host(`homeassistant.puyral.fr`)";
      "traefik.http.routers.homeassistant.tls.certresolver" = "ovh";
      "traefik.http.services.homeassistant.loadbalancer.server.port" = "8123";
    };
    dependsOn = [ "mosquitto" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=homeassistant"
      "--network=homeassistant_ha"
      "--network=traefik"
    ];
  };
  systemd.services."docker-homeassistant" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [ "docker-network-homeassistant_ha.service" ];
    requires = [ "docker-network-homeassistant_ha.service" ];
    partOf = [ "docker-compose-homeassistant-root.target" ];
    wantedBy = [ "docker-compose-homeassistant-root.target" ];
  };
  virtualisation.oci-containers.containers."mosquitto" = {
    image = "eclipse-mosquitto:latest";
    environment = {
      "TZ" = "Europe/Vienna";
    };
    volumes = [ "/containers/mosquitto:/mosquitto:rw" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=mosquitto"
      "--network=homeassistant_ha"
    ];
  };
  systemd.services."docker-mosquitto" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [ "docker-network-homeassistant_ha.service" ];
    requires = [ "docker-network-homeassistant_ha.service" ];
    partOf = [ "docker-compose-homeassistant-root.target" ];
    wantedBy = [ "docker-compose-homeassistant-root.target" ];
  };
  virtualisation.oci-containers.containers."zigbee2mqtt" = {
    image = "koenkk/zigbee2mqtt:latest";
    environment = {
      "TZ" = "Europe/Vienna";
    };
    volumes = [
      "/containers/zigbee2mqtt:/app/data:rw"
      "/run/udev:/run/udev:ro"
    ];
    labels = {
      "traefik.enable" = "true";
      "traefik.http.routers.zigbee2mqtt.entrypoints" = "https";
      "traefik.http.routers.zigbee2mqtt.rule" = "Host(`zigbee2mqtt.puyral.fr`)";
      "traefik.http.routers.zigbee2mqtt.tls.certresolver" = "ovh";
      "traefik.http.services.zigbee2mqtt.loadbalancer.server.port" = "8123";
    };
    dependsOn = [ "mosquitto" ];
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c969fdb7c12ec119aa120c7bd930c07-if00-port0:/dev/ttyUSB0"
      "--network-alias=zigbee2mqtt"
      "--network=homeassistant_ha"
      "--network=traefik"
    ];
  };
  systemd.services."docker-zigbee2mqtt" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [ "docker-network-homeassistant_ha.service" ];
    requires = [ "docker-network-homeassistant_ha.service" ];
    partOf = [ "docker-compose-homeassistant-root.target" ];
    wantedBy = [ "docker-compose-homeassistant-root.target" ];
  };

  # Networks
  systemd.services."docker-network-homeassistant_ha" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f homeassistant_ha";
    };
    script = ''
      docker network inspect homeassistant_ha || docker network create homeassistant_ha
    '';
    partOf = [ "docker-compose-homeassistant-root.target" ];
    wantedBy = [ "docker-compose-homeassistant-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-homeassistant-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
