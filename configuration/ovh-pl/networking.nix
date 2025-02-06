{...}:{
	  networking = {
    defaultGateway6 = "2001:41d0:601:1100::1";
    enableIPv6 = true;
    interfaces = {
      ens3 = {
        ipv6.addresses = [
          { address="2001:41d0:601:1100::6b0e"; prefixLength=64; }
        ];
        #ipv6.routes = [ { address = "2001:41d0:601:1100::1"; } ];
      };
    };
  };
}
