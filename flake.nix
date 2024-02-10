{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-std.url = "github:chessai/nix-std"; # https://github.com/chessai/nix-std
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs: 
{
    nixosConfigurations.nixomagus = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ 
	./configuration.nix
	home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.simon = import ./users/simon/main.nix ;
            home-manager.extraSpecialArgs = {system = system;};

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
	];
    };
  };
}
