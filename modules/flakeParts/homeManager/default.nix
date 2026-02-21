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
    computer: username:
    let
      inherit (computer) system users;
      inherit (self) rootDir;
      user = users.${username};
    in

    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      extraSpecialArgs = self.lib.extraArgs computer;
      modules = with inputs; [
        self.homeModules.default
        sops-nix.homeManagerModules.sops
        (flake-parts-lib.importApply (rootDir + /users) { inherit user self; })
      ];
    };

  genConfigs =
    with lib;
    computers:
    concatLists (
      mapAttrsToList (
        key: computer:
        map (username: {
          name = "${username}@${key}";
          value = mk computer username;
        }) (attrNames computer.users)
      ) (filterAttrs (_: c: c.homeManager.enable && !c.nixos.enable) computers)
    );

in

{
  flake.homeConfigurations = lib.listToAttrs (genConfigs config.computers);
}
