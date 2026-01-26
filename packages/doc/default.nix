{
  pkgs,
  rootDir,
  lib,
  machine ? "dynas",
  ...
}@args:

let
  # Import functions from lib/default.nix
  # args contains all inputs (nixpkgs, etc) because they are passed in pkgsArgs
  functions = (import (rootDir + "/lib/default.nix")) rootDir args;

  # Load computer configurations
  computers = (import (rootDir + "/computers.nix")).computers;

  # Select a reference computer (e.g., 'amdra')
  computer = computers."${machine}" // {
    name = machine;
  };

  # Evaluate the system configuration
  eval = functions.mkSystem {
    inherit computer;
    extraModules = [
      (
        { config, ... }:
        {
          vars.Zeno.mountPoint = "/tmp/dummy-zeno";
        }
      )
    ];
  };

  # Filter options to only include those defined in this repository (under rootDir)
  # We check if any declaration file starts with the rootDir path.
  transformOptions =
    opt:
    let
      isLocal = builtins.any (decl: lib.hasPrefix (toString rootDir) (toString decl)) opt.declarations;
    in
    if isLocal then opt else opt // { visible = false; };

  # Generate documentation
  doc = pkgs.nixosOptionsDoc {
    options = eval.options;
    inherit transformOptions;
    warningsAreErrors = false;
  };

  markdown = doc.optionsCommonMark;
in
pkgs.runCommand "nix-configuration-doc"
  {
    nativeBuildInputs = [ pkgs.mdbook ];
  }
  ''
    mkdir -p src
    cp ${markdown} src/nixos-options.md

    cat > book.toml <<EOF
    [book]
    title = "NixOS Configuration Options"
    EOF

    cat > src/SUMMARY.md <<EOF
    # Summary
    [NixOS Options](./nixos-options.md)
    EOF

    mdbook build -d $out
  ''
