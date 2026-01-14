{
  description = "Nix configuration";

  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # for rapid photo downloader
    nixpkgs-rpd.url = "nixpkgs/a493e93b4a259cd9fea8073f89a7ed9b1c5a1da2";

    # Pinned kernel (Linux 6.17) to support ZFS Stable + Intel Arc
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/addf7cf5f383a3101ecfba091b98d0a1263dc9b8";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    # nix-std.url = "github:chessai/nix-std"; # https://github.com/chessai/nix-std

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    custom = {
      url = "github:puyral/custom-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.cryptovampire-src.follows = "nixpkgs-stable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # see https://github.com/tale/headplane/pull/282
    headplane = {
      url = "github:tale/headplane/v0.6.1";
      # url = "github:tale/headplane"; # master
      # url = "github:tale/headplane/bd8a7a56d4021edf58511c6ab333af864d91304c";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      flake-utils,
      treefmt-nix,
      nixpkgs-unstable,
      nixpkgs-stable,
      sops-nix,
      ...
    }@attrs:
    let
      functions = (import ./lib) ./. (attrs // { nixpkgs = nixpkgs-stable; });
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs-stable = (functions.mkpkgs system).pkgs-stable;
        pkgs-unstable = (functions.mkpkgs system).pkgs-unstable;
        pkgs = pkgs-stable;
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
          (
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
