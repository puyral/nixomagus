{ pkgs, ... }:
{
devShells.lean =  pkgs.mkShell {
  name = "lean";
  buildInputs = with pkgs; [
    elan
    nixd
  ];
}
;}