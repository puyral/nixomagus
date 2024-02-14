{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-std.url = "github:chessai/nix-std"; # https://github.com/chessai/nix-std

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    custom = {
      url = "github:puyral/custom-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, kmonad, custom, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.nixomagus = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = attrs;
        modules = [
          ./configuration.nix
          kmonad.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.simon = import ./users/simon/main.nix;
            home-manager.extraSpecialArgs = {
              system = system;
              custom = custom.packages.${system};
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
