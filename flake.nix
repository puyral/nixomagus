{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    my-nixpkgs.url = "github:puyral/nixpkgs/in-use";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-std.url = "github:chessai/nix-std"; # https://github.com/chessai/nix-std

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    custom = {
      url = "github:puyral/custom-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.cryptovampire-src.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      flake-utils,
      treefmt-nix,
      ...
    }@attrs:
    let
      functions = (import ./lib) ./. attrs;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (functions.mkpkgs system).pkgs;
        pkgs-unstable = (functions.mkpkgs system).pkgs-unstable;
        # Eval the treefmt modules from ./treefmt.nix
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./fmt.nix;
      in
      {

        formatter = treefmtEval.config.build.wrapper;
        checks = {
          # formatting = treefmtEval.config.build.check self;
        };

        devShells.default = import ./shell.nix { inherit pkgs pkgs-unstable; };
      }
    )
    // (
      let
        computers = (import ./computers.nix);
      in
      with functions;
      {
        homeConfigurations = mkHomes computers;
        nixosConfigurations = mkSystems computers;
      }
    )
  ;
}
