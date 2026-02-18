{
  inputs,
  ...
}:
{
  imports = [ ./squirrel ];
  perSystem =
    { inputs', pkgs, ... }:
    let
      mkPkgs =
        file:
        let
          p = pkgs.callPackage file inputs;
        in
        {
          name = p.pname or p.name;
          value = p;
        };

      packages = [
        ./generate-jpgs
        ./notify-done
        ./paperless-ai
        ./rebuild
        ./swww-change-wp
        ./wandarr
      ];

      mainPkgs = with builtins; listToAttrs (map mkPkgs packages);
      # squirrel = pkgs.ocamlPackages.callPackage ./squirrel {
      #   squirrel-prover-src = inputs'.squirrel-prover-src;
      # };

      re-exports = with inputs'; {
        sops-nix = sops-nix.packages.default;
        darktable-jpeg-sync = darktable-jpeg-sync.packages.default;
      };
    in
    {

      packages = mainPkgs // re-exports;
    };
}
