attrs@{
  home-manager,
  nixpkgs,
  nixpkgs-unstable,
  custom,
  ...
}:
rec {
  # mkHomes= with builtins; computers: merge (mapAttrs (name: value: merge (map (user: mkHome {computer = ({inherit name;} // value); inherit user;} ) value.users)) computers);
  # mkSystems = with builtins; computers: merge (mapAttrs (name: value: mkSystem ({inherit name;} // value)) (filter (c: c.nixos) copmuters)); 

  mkHomes =
    computers:
    builtins.mapAttrs (
      name: value:
      let
        computer = {
          inherit name;
        } // value;
        homes = builtins.map (user: {
          name = user.name;
          value = mkHome { inherit computer user; };
        }) computer.users;
      in
      builtins.listToAttrs homes
    ) computers;

  mkSystems = computers: builtins.mapAttrs (name: value: mkSystem ({ inherit name; } // value));

  mkHome =
    inputs@{ computer, user }:
    home-manager.lib.homeManagerConfiguration {
      # system = computer.system;
      # homeDirectory = defaultHome user; 
      # username = user.name; 
      # configuration.imports = [ ./home.nix ];
      pkgs = (mkpkgs computer).pkgs;
      modules = mkHomeModules inputs;
      extraSpecialArgs = mkExtraArgs inputs;
    };

  mkHomeModules =
    { computer, user }:
    [
      (../users + "/${user.name}/home.nix")
      (../users + "${user.name}/${computer.name}.nix")
    ];

  mkSystem =
    inputs@{ computer, ... }:
    let
      homes = home-manager.nixosModules.home-manager {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = mkExtraArgs inputs;
          users = builtins.listToAttrs (
            builtins.map (user: {
              name = user.name;
              value = asModules (mkHomeModules {
                inherit computer user;
              });
            }) computer.users
          );
        };
      };

    in
    nixpkgs.lib.nixosSystem {
      specialArgs = attrs // mkExtraArgs inputs;
      system = computer.system;
      modules = [
        ./commun.nix
        (./. + "/${computer.name}")
        homes
      ];
    };

  mkpkgs = system: {
    pkgs = nixpkgs.legacyPackages.${system};
    # pkgs-unstable = (nixpkgs-unstable // {config.allowUnfree = true;}).legacyPackages.${system};
    pkgs-unstable = import nixpkgs-unstable {
      system = system;
      config = {
        allowUnfree = true;
      };
    }; # https://www.reddit.com/r/NixOS/comments/17p39u6/how_to_allow_unfree_packages_from_stable_and/
  };
  mkExtraArgs =
    { computer, ... }:
    let
      overlays = (import ./overlays.nix) computer;
      system = computer.system;
      pkgs = (mkpkgs computer.system).pkgs;
      pkgs-unstable = (mkpkgs computer.system).pkgs-unstable;
    in
    {

      custom = custom.packages.${computer.system};
      computer_name = computer.name;
      mconfig = computer;
      inherit system pkgs-unstable overlays;
    };

  asModules = inputs: modules: merge (builtins.map (m: m inputs) modules);

  merge = builtins.foldl' (acc: elem: acc // elem) { };
}
