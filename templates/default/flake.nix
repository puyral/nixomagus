{
  description = "default flake";

  inputs = {
    nixpkgs.url = "nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (attrs: {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.callPackage ./shell.nix { };

        treefmt.programs = {
          nixfmt.enable = true;
        };
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

    });
}