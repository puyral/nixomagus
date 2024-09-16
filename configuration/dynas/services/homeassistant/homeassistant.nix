gconfig: vars:
{ ... }:
{

  services.home-assistant = {
    enable = true;
    configDir = "/data/ha";
    openFirewall = true;
    extraPackages = python3Packages: with python3Packages; [ gtts paho-mqtt];
    config = {
      homeassistant = {
        unit_system = "metric";
        temperature_unit = "C";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = gconfig.containers.ha.hostAddress;
      };
    };
  };
}
