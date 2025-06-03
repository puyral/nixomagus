rootDir:
attrs@{
  home-manager,
  nixpkgs-stable,
  nixpkgs-unstable,
  nixpkgs,
  custom,
  self,
  sops-nix,
  # paperless-nixpkgs,
  nixpkgs-rapid-photo-downloader,
  ...
}:
rec {
  mlib = with (import ./utils.nix); {
    inherit enumerate;
  };

  mkHomes =
    { computers, ... }:
    with builtins;
    let
      names = builtins.attrNames computers;
      as_list = builtins.concatLists (builtins.map (name: to_user_list name computers.${name}) names);
      to_user_list =
        name: c:
        builtins.map (user: {
          name = "${user.name}@${name}";
          value = {
            inherit user;
            computer = c // {
              inherit name;
            };
          };
        }) c.users;
      to_home =
        { name, value }:
        {
          inherit name;
          value = mkHome value;
        };
      as_list_home = builtins.map to_home as_list;
    in
    (builtins.listToAttrs as_list_home);

  mkSystems =
    { computers, ... }:
    with builtins;
    (
      let
        nixosComputers =
          with builtins;
          let
            names = attrNames computers;
            nixosNames = filter (name: builtins.hasAttr "nixos" computers.${name}) names;
            list = map (name: {
              inherit name;
              value = computers.${name};
            }) nixosNames;
          in
          listToAttrs list;
      in
      builtins.mapAttrs (
        name: value:
        mkSystem {
          computer = {
            inherit name;
          } // value;
        }
      ) nixosComputers
    );

  mkHome =
    inputs@{ computer, user }:
    home-manager.lib.homeManagerConfiguration {
      modules = [
        ((import (rootDir + /home_manager.nix)) user)
        sops-nix.homeManagerModules.sops
      ];
      pkgs = (mkpkgs computer.system).pkgs;
      extraSpecialArgs = (mkExtraArgs inputs) // {
        inherit computer;
        is_nixos = false;
      };
    };

  mkSystem =
    inputs@{ computer, ... }:
    let
      usersAndModules = builtins.map (user: {
        name = user.name;
        value = (import (rootDir + /home_manager.nix)) user;
      }) computer.users;
      homes = {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = (mkExtraArgs inputs) // {
            inherit computer;
            is_nixos = true;
          };
          sharedModules = [
            sops-nix.homeManagerModules.sops
          ];
          users = builtins.listToAttrs usersAndModules;
        };
      };

    in
    nixpkgs.lib.nixosSystem {
      specialArgs = attrs // mkExtraArgs inputs;
      system = computer.system;
      modules = [
        sops-nix.nixosModules.sops
        (rootDir + /modules/nixos)
        (rootDir + /configuration/commun)
        (rootDir + /configuration + "/${computer.name}")
        home-manager.nixosModules.home-manager
        homes
      ];
    };

  mkpkgs =
    system:
    let
      aux =
        nixpkgs:
        import nixpkgs {
          system = system;
          config = {
            allowUnfree = true;
          };
        };
    in
    rec {
      # pkgs = nixpkgs.legacyPackages.${system};
      # # pkgs-unstable = (nixpkgs-unstable // {config.allowUnfree = true;}).legacyPackages.${system};
      # pkgs-unstable = import nixpkgs-unstable {
      #   system = system;
      #   config = {
      #     allowUnfree = true;
      #   };
      # }; # https://www.reddit.com/r/NixOS/comments/17p39u6/how_to_allow_unfree_packages_from_stable_and/
      pkgs = aux nixpkgs;
      pkgs-stable = aux nixpkgs-stable;
      pkgs-unstable = aux nixpkgs-unstable;
      pkgs-rapid-photo-downloader = aux nixpkgs-rapid-photo-downloader;
      extra-pkgs = pkgs.lib.mapAttrs (name: value: value.legacyPackages.${system}) {
        # inherit paperless-nixpkgs;
      };
      pkgs-self = self.packages.${system};
    };

  mkExtraArgs' =
    system:
    let
      pkgs-attr = (mkpkgs system);
      pkgs = pkgs-attr.pkgs;
      pkgs-stable = pkgs-attr.pkgs-stable;
      pkgs-unstable = pkgs-attr.pkgs-unstable;
      pkgs-rapid-photo-downloader = pkgs-attr.pkgs-rapid-photo-downloader;
      extra-pkgs = pkgs-attr.extra-pkgs;
      pkgs-self = pkgs-attr.pkgs-self;
    in
    attrs
    // {
      custom = custom.packages.${system};
      inherit
        system
        pkgs-unstable
        pkgs-stable
        rootDir
        mlib
        extra-pkgs
        pkgs-self
        pkgs-rapid-photo-downloader
        ;
    };

  mkExtraArgs =
    { computer, ... }:
    (mkExtraArgs' computer.system)
    // {
      computer_name = computer.name;
      mconfig = computer;
      overlays = (import (rootDir + /overlays)) computer;
    };

  # asModules = modules: inputs: merge (builtins.map (m: (import m) inputs) modules);

  # merge = builtins.foldl' (acc: elem: acc // elem) { };
}
