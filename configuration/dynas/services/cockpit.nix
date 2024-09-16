{ config, ... }:
let
  domain = config.networking.reverse_proxy."cockpit".domain;
in
{
  services.cockpit = {
    enable = true;
    openFirewall = true;
    settings = {
      # WebService = {
      # Origins = "https://cockpit.${domain} wss://cockpit.${domain}";
      # ProtocolHeader = "X-Forwarded-Proto";};
    };
  };
  # networking.reverse_proxy."cockpit".port = config.services.cockpit.port;
  # 9090
}
