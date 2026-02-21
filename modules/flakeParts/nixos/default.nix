{
  lib,
  config,
  inputs,
  self,
  flake-parts-lib,
  ...
}:
let
  mk =
    computer:
    let
      inherit (computer) system users;
      inherit (self) rootDir;
      specialArgs = self.lib.extraArgs computer;

      homes = {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = specialArgs;
          sharedModules = [
            self.homeModules.default
            inputs.sops-nix.homeManagerModules.sops
          ];
          users = lib.mapAttrs (
            _: user: (flake-parts-lib.importApply (rootDir + /home_manager.nix) { inherit user self; })
          ) users;
        };
      };

    in

    inputs.nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = with inputs; [
        simple-nixos-mailserver.nixosModules.mailserver
        sops-nix.nixosModules.sops
        self.nixosModules.default
        (rootDir + /configuration/commun)
        (rootDir + /configuration + "/${computer.name}")
        home-manager.nixosModules.home-manager
        homes
      ];
    };
in

{
  flake.nixosConfigurations =
    with lib;
    (mapAttrs (_: v: mk v)) (filterAttrs (_: c: c.nixos.enable) config.computers);
}
