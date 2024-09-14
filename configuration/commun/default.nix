{computer, ...}:let
  extensions = [ ../extensions/isw ];
{
  imports = [
    ./configuraton.nix
    ./filesystem.nix
    ] ++ extensions
}