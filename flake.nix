{
  description = "Nix configuration";

  inputs = {
    ########################
    ####### nixpkgs ########
    ########################

    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Pinned kernel (Linux 6.17) to support ZFS Stable + Intel Arc
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/addf7cf5f383a3101ecfba091b98d0a1263dc9b8";

    #######################
    ####### modules #######
    #######################

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";
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

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    ######################
    ###### packages ######
    ######################

    darktable-jpeg-sync = {
      url = "github:puyral/darktable-jpeg-sync";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    paperless-ai-src = {
      url = "github:clusterzx/paperless-ai";
      flake = false;
    };

    squirrel-prover-src = {
      url = "github:squirrel-prover/squirrel-prover";
      flake = false;
    };

    custom = {
      url = "github:puyral/custom-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        cryptovampire-src.follows = "nixpkgs-stable";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    #######################
    ######## utils ########
    #######################

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    {
      flake-utils,
      treefmt-nix,
      nixpkgs-unstable,
      nixpkgs-stable,
      sops-nix,
      darktable-jpeg-sync,
      squirrel-prover-src,
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
            darktable-jpeg-sync = darktable-jpeg-sync.packages.${system}.default;
            squirrel = pkgs.ocamlPackages.callPackage ./packages/squirrel { inherit squirrel-prover-src; };
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
