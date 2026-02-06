{ writeShellScriptBin, nixos-shell, system, ... }:
let
  nixosShellPkg = nixos-shell.packages.${system}.nixos-shell;
in
writeShellScriptBin "sss" ''
  exec ${nixosShellPkg}/bin/nixos-shell --flake /config#shell --container --mount "$PWD":/cwd "$@"
''
