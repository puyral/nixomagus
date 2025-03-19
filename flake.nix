{
  description = "Nix configuration";

  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    my-nixpkgs.url = "github:puyral/nixpkgs/in-use";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager"; # /release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # nix-std.url = "github:chessai/nix-std"; # https://github.com/chessai/nix-std

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    custom = {
      url = "github:puyral/custom-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.cryptovampire-src.follows = "nixpkgs-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      flake-utils,
      treefmt-nix,
      nixpkgs-unstable,
      ...
    }@attrs:
    let
      functions = (import ./lib) ./. (attrs // { nixpkgs = nixpkgs-unstable; });
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs-stable = (functions.mkpkgs system).pkgs-stable;
        pkgs-unstable = (functions.mkpkgs system).pkgs-unstable;
        pkgs = pkgs-unstable;
        # Eval the treefmt modules from ./treefmt.nix
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./fmt.nix;
      in
      {

        formatter = treefmtEval.config.build.wrapper;
        checks = {
          # formatting = treefmtEval.config.build.check self;
        };

        devShells.default = import ./shell.nix { inherit pkgs pkgs-stable pkgs-unstable; };
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
    );
}
