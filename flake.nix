{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs: 
{
    nixosConfigurations.nixomagus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ 
	./configuration.nix
	home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.simon = import ./users/simon/main.nix ;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          } 
	];
    };
  };
}
