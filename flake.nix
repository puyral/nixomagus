{
  description = "Nix configuration";

  inputs = {
    ########################
    ####### nixpkgs ########
    ########################

    nixpkgs-stable.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    # Pinned kernel (Linux 6.17) to support ZFS Stable + Intel Arc
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/addf7cf5f383a3101ecfba091b98d0a1263dc9b8";

    #######################
    ####### modules #######
    #######################

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    ######################
    ###### packages ######
    ######################

    darktable-jpeg-sync = {
      url = "github:puyral/darktable-jpeg-sync";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        flake-utils.follows = "flake-utils";
      };
    };

    paperless-ai-src = {
      url = "github:clusterzx/paperless-ai";
      flake = false;
    };

    squirrel-prover-src = {
      # url = "github:squirrel-prover/squirrel-prover/58ea3d1c2db38ce9639dd1c17c9885c483c56472";
      url = "github:squirrel-prover/squirrel-prover/1ce3981473e9bec7ca36205dd77fcd0941b84728";
      flake = false;
    };

    lean-lsp-mcp = {
      url = "github:oOo0oOo/lean-lsp-mcp";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    isw-src = {
      url = "github:YoyPa/isw";
      flake = false;
    };

    surface-dtx-daemon-src = {
      url = "github:linux-surface/surface-dtx-daemon";
      flake = false;
    };

    lspranto = {
      url = "github:puyral/lspranto";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable"; # using "nixpkgs" crashes
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    #######################
    ######## utils ########
    #######################

    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

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

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (attrs: {
      imports = [
        inputs.home-manager.flakeModules.home-manager
        ./computers.nix
        ./fmt.nix
        ./packages
        ./devShells
        ./modules
      ];

      systems = [ "x86_64-linux" ];

      flake.rootDir = ./.;
    });
}
