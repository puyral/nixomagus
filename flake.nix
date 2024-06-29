{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-std.url = "github:chessai/nix-std"; # https://github.com/chessai/nix-std

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    custom = {
      url = "github:puyral/custom-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      kmonad,
      custom,
      nixpkgs-unstable,
      flake-utils,
      ...
    }@attrs:
    let
      mkpkgs = system: {

        pkgs = nixpkgs.legacyPackages.${system};
        # pkgs-unstable = (nixpkgs-unstable // {config.allowUnfree = true;}).legacyPackages.${system};
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config = {
            allowUnfree = true;
          };
        }; # https://www.reddit.com/r/NixOS/comments/17p39u6/how_to_allow_unfree_packages_from_stable_and/
      };
    in

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (mkpkgs system).pkgs;
        pkgs-unstable = (mkpkgs system).pkgs-unstable;
      in
      {

        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = pkgs.mkShell {
          name = "config";
          buildInputs =
            (with pkgs-unstable; [
              nil
              wev
              xorg.xev
              arandr
            ])
            ++ (with pkgs; [
              vim
              git
              git-crypt
              gh
              gnupg
            ]);
        };
      }
    )
    // ({
      nixosConfigurations = builtins.mapAttrs (
        name: config:
        let
          system = config.system;
          pkgs = (mkpkgs system).pkgs;
          pkgs-unstable = (mkpkgs system).pkgs-unstable;
        in
        nixpkgs.lib.nixosSystem {
          # system = system;
          inherit system;
          specialArgs = attrs // {
            inherit pkgs-unstable;
          };
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
                inherit system pkgs-unstable config;
              };

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        }
      ) (import ./computers.nix);
    })

  ;
}
