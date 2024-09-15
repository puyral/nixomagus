{ rootDir, ... }:

{

  services.zerotierone =
    let
      networks = import (rootDir + /secrets/zerotier-networks.nix);
    in
    {
      enable = true;
      joinNetworks = [ networks.vidya.id ];
    };
}
