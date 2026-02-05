{ ... }:
{
  networking = {
    defaultGateway6 = "2001:41d0:601:1100::1";
    enableIPv6 = true;
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv6.addresses = [
          {
            address = "2001:41d0:601:1100::6b0e";
            prefixLength = 64;
          }
        ];
        ipv4.addresses = [
          {
            address = "57.128.196.62";
            prefixLength = 32;
          }
        ];
        ipv4.routes = [
          {
            address = "57.128.196.1";
            prefixLength = 32;
            options = {
              scope = "link";
            };
          }
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = "57.128.196.1";
          }
        ];
        #ipv6.routes = [ { address = "2001:41d0:601:1100::1"; } ];
      };
    };
  };
}
