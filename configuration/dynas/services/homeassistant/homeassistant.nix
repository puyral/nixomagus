gconfig: vars:
{ ... }:
{

  services.home-assistant = {
    enable = true;
    configDir = "/data/ha";
    openFirewall = true;
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
