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
        # ./notify-done
        ./paperless-ai
        ./rebuild
        ./swww-change-wp
        ./wandarr
      ];

      mainPkgs =
        with builtins;
        (pkgs.callPackages ./notify-done inputs) // listToAttrs (map mkPkgs packages);

      re-exports =
        with inputs';
        {
          sops-nix = sops-nix.packages.default;
          darktable-jpeg-sync = darktable-jpeg-sync.packages.default;
        }
        // lean-lsp-mcp.packages;
    in
    {

      packages = mainPkgs // re-exports;
    };
}
