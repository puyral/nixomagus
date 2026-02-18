{
  description = "Nix configuration";

  inputs = {
    ########################
    ####### nixpkgs ########
    ########################

    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    # Pinned kernel (Linux 6.17) to support ZFS Stable + Intel Arc
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/addf7cf5f383a3101ecfba091b98d0a1263dc9b8";

    #######################
    ####### modules #######
    #######################

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # see https://github.com/tale/headplane/pull/282
    headplane = {
      url = "github:tale/headplane/v0.6.1";
      # url = "github:tale/headplane"; # master
      # url = "github:tale/headplane/bd8a7a56d4021edf58511c6ab333af864d91304c";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    ######################
    ###### packages ######
    ######################

    darktable-jpeg-sync = {
      url = "github:puyral/darktable-jpeg-sync";
      inputs.nixpkgs.follows = "nixpkgs";
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
        nixpkgs.follows = "nixpkgs";
        cryptovampire-src.follows = "nixpkgs";
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

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      attrs:
      let
        functions = (import ./lib) ./. (attrs);
        computers = (import ./computers.nix);
      in
      {
        imports = [
          ./fmt.nix
          ./packages
          ./devShells
        ];

        systems = [ "x86_64-linux" ];

        flake = {
          # inherit inputs;
          homeConfigurations = functions.mkHomes computers;
          nixosConfigurations = functions.mkSystems computers;
        };
      }
    );
}
