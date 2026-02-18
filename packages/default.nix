{...}:{
  perSystem = {pkgs, inputs, ...} : 
  let
    mkPkgs = file: let p = pkgs.callPackage file inputs; in {name = p.name; value = p;};

    packages = [
      ./generate-jpgs
      ./notify-done
      ./paperless-ai
      ./rebuild
      ./swww-change-wp
      ./wandarr
    ];

    mainPkgs = 
  with builtins; listToAttrs (map mkPkgs packages);

  squirrel = pkgs.ocamlPackages.callPackages ./squirrel inputs;
   in
    mainPkgs // squirrel;
}