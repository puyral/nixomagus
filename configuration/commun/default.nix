{ computer, ... }:
let
  extensions = [ ../extensions/isw ];
in
{
  imports = [
    ./configuraton.nix
    ./filesystem.nix
  ] ++ extensions;
}
