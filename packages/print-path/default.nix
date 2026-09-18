{ writeShellApplication, lib, ... }:
lib.setName "print-path" (writeShellApplication {
  name = "p";
  text = builtins.readFile ./script.sh;
})
