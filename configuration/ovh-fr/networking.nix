{ ... }:
let
  ipv4 = "146.59.228.61";
  ipv6 = "2001:41d0:304:200::c5eb";
  gatewayv4 = "146.59.228.1";
  gatewayv6 = "2001:41d0:304:200::1";
in
{
  networking = {
    nameservers = [ "1.1.1.1" ];
    defaultGateway6 = gatewayv6;
    enableIPv6 = true;
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv6.addresses = [
          {
            address = ipv6;
            prefixLength = 64;
          }
        ];
        ipv4.addresses = [
          {
            address = ipv4;
            prefixLength = 32;
          }
        ];
        ipv4.routes = [
          {
            address = gatewayv4;
            prefixLength = 32;
            options = {
              scope = "link";
            };
          }
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = gatewayv4;
          }
        ];
        #ipv6.routes = [ { address = "2001:41d0:601:1100::1"; } ];
      };
    };
  };
}
