{ computer, ... }:
{
  imports = [
    (./. + "/${computer.name}")
    ./commun
  ];
}
