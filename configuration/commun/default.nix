{ computer, ... }:

{
  imports = [
    ./configuration.nix
    ./filesystem.nix
    ./services
  ];
}
