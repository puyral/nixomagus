{
  description = "Nix configuration";

  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # https://github.com/NixOS/nixpkgs/pull/427813
    nixpkgs-libsoup-escape.url = "nixpkgs/30e2e2857ba47844aa71991daa6ed1fc678bcbb7";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager"; # /release-25.05";
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

    turboprint-nix = {
      url = "github:puyral/turboprint-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        treefmt-nix.follows = "treefmt-nix";
        flake-utils.follows = "flake-utils";
      };
    };

    # see https://github.com/tale/headplane/pull/282
    headplane = {
      # url = "github:tale/headplane/v0.6.0";
      url = "github:tale/headplane/1ce0dc375e88b371110756a913b62d1e9d9cf679";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      flake-utils,
      treefmt-nix,
      nixpkgs-unstable,
      nixpkgs-stable,
      turboprint-nix,
      sops-nix,
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
        l = pkgs.lib;

        # Eval the treefmt modules from ./treefmt.nix
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./fmt.nix;

        pkgsArgs = functions.mkExtraArgs' system;

        mkName = file: l.removeSuffix ".nix" file;

        devShells =
          let
            dir = "devShells";
            files = builtins.readDir ./${dir};
          in
          l.mapAttrs' (file: _: {
            name = mkName file;
            value = pkgs.callPackage ./${dir}/${file} (pkgsArgs // packages);
          }) files;

        packages =
          turboprint-nix.packages.${system}
          // (
            let
              dir = "packages";
              files = builtins.readDir ./${dir};
            in
            l.mapAttrs' (file: _: {
              name = mkName file;
              value = pkgs.callPackage ./${dir}/${file} pkgsArgs;
            }) files
          )
          // {
            sops-nix = sops-nix.packages.${system}.default;
          };
      in
      {
        inherit devShells packages;

        formatter = treefmtEval.config.build.wrapper;
        checks = {
          # formatting = treefmtEval.config.build.check self;
        };
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
