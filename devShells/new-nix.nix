{ mkShell, nixVersions, ... }:
mkShell {
  packages = [ nixVersions.latest ];
}
