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
      functions = (import ./functions) ./. attrs;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (functions.mkpkgs system).pkgs;
        pkgs-unstable = (functions.mkpkgs system).pkgs-unstable;
      in
      {

        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = pkgs.mkShell {
          name = "config";
          buildInputs =
            (with pkgs-unstable; [ compose2nix ])
            ++ (with pkgs; [
              vim
              git
              git-crypt
              gh
              gnupg

            ])
            ++ (
              if pkgs.stdenv.isDarwin then
                [ ]
              else
                (with pkgs-unstable; [
                  wev
                  xorg.xev
                  arandr
                ])
            );
        };
      }
    )
    // (
      let
        computers = (import ./computers.nix);
      in
      with functions;
      {
        homeConfigurations = mkHomes computers;
        nixosConfigurations = mkSystems computers;
      }
    )
  # (mkHomes computers) // (mkSystem computers))

  ;
}
