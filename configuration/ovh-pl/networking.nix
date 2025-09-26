{ ... }:
{
  networking = {
    defaultGateway6 = "2001:41d0:601:1100::1";
    defaultGateway = {
      address = "57.128.196.1";
      interface = "ens3";
    };
    enableIPv6 = true;
    interfaces = {
      ens3 = {
        useDHCP = true;
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
        #ipv6.routes = [ { address = "2001:41d0:601:1100::1"; } ];
      };
    };
  };
}
