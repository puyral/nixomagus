{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./syncthing.nix
    ./zerotierone.nix
  ];
}
