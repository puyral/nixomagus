attrs@{
  home-manager,
  nixpkgs,
  nixpkgs-unstable,
  custom,
  ...
}:
rec {
  mkHomes =
    { computers, ... }:
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

  mkSystems =
    { computers, ... }:
    let
      nixosComputers =
        with builtins;
        let
          names = attrNames computers;
          nixosNames = filter (name: computers.${name}.nixos) names;
          list = map (name: {
            inherit name;
            value = computers.${name};
          }) nixosNames;
        in
        listToAttrs list;
    in
    builtins.mapAttrs (
      name: value:
      mkSystem ({
        computer = {
          inherit name;
        } // value;
      })
    ) nixosComputers;

  mkHome =
    inputs@{ computer, user }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = (mkpkgs computer).pkgs;
      extraSpecialArgs = mkExtraArgs inputs;
    };

  mkSystem =
    inputs@{ computer, ... }:
    let
      usersAndModules = builtins.map (user: {
        name = user.name;
        value = (import ../home_manager.nix) user;
      }) computer.users;
      homes = {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = mkExtraArgs inputs // {
            inherit computer;
          };
          users = builtins.listToAttrs usersAndModules;
        };
      };

    in
    nixpkgs.lib.nixosSystem {
      specialArgs = attrs // mkExtraArgs inputs;
      system = computer.system;
      modules = [
        ../commun.nix
        (../configuration + "/${computer.name}")
        home-manager.nixosModules.home-manager
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
      overlays = (import ../overlays) computer;
      system = computer.system;
      pkgs = (mkpkgs computer.system).pkgs;
      pkgs-unstable = (mkpkgs computer.system).pkgs-unstable;
    in
    {

      custom = custom.packages.${computer.system};
      computer_name = computer.name;
      mconfig = computer;
      # functions = {inherit mkHomeModules;};
      inherit system pkgs-unstable overlays;
    };

  asModules = modules: inputs: merge (builtins.map (m: (import m) inputs) modules);

  merge = builtins.foldl' (acc: elem: acc // elem) { };
}
