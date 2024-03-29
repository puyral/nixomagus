{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-std.url = "github:chessai/nix-std"; # https://github.com/chessai/nix-std

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    custom = {
      url = "github:puyral/custom-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, home-manager, kmonad, custom, nixpkgs-unstable, ...
    }@attrs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # pkgs-unstable = (nixpkgs-unstable // {config.allowUnfree = true;}).legacyPackages.${system};
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      }; # https://www.reddit.com/r/NixOS/comments/17p39u6/how_to_allow_unfree_packages_from_stable_and/
    in {
      nixosConfigurations.nixomagus = nixpkgs.lib.nixosSystem {
        # system = system;
        inherit system;
        specialArgs = attrs // { inherit pkgs-unstable; };
        modules = [
          ./configuration.nix
          kmonad.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.simon = import ./users/simon/main.nix;
            home-manager.extraSpecialArgs = {
              # system = system;
              custom = custom.packages.${system};
              inherit system pkgs-unstable;
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };

      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default =
        pkgs.mkShell { buildInputs = with pkgs; [ nil wev ]; };
    };
}
