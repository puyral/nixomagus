{ computer, ... }:

{
  imports = [
    ./configuration.nix
    # ./filesystem.nix
    ./services
    ./network.nix
  ];
}
