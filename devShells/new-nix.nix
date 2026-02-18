{pkgs,...}:
{devShells.new-nix = with pkgs;
mkShell {
  packages = [ nixVersions.latest ];
};}
