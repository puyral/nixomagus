{ mkShell, cargo, ... }:
mkShell {
  name = "config";
  buildInputs = [
    cargo
  ];
}
