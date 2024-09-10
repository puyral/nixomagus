user:
{ computer, ... }:
{
  imports = [
    (./users + "/${user.name}/home.nix")
    (./users + "/${user.name}/${computer.name}.nix")
  ];
}
