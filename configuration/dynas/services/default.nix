{ ... }:
{
  imports = [
    ./nfs.nix
    ./samba.nix
    ./cockpit.nix
    ./syncthing.nix
    ./whatchtower.nix
    ./jellyfin.nix
  ];

  #   networking.nat = {
  #   enable = true;
  #   internalInterfaces = ["ve-+"];
  #   externalInterface = "enp9s0";
  #   # Lazy IPv6 connectivity for the container
  #   enableIPv6 = true;
  # };
}
