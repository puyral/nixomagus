{
  inputs,
  self,
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
          p = pkgs.callPackage file pkgsInputs;
        in
        {
          name = p.pname or p.name;
          value = p;
        };
      pkgs-unstable = inputs'.nixpkgs-unstable.legacyPackages;

      packages = [
        ./generate-jpgs
        ./paperless-ai
        ./rebuild
        ./awww-change-wp
        ./wandarr
        ./probe-rs-udev
        ./rnote
        ./isw
        ./kavita
        ./surface-dtx-daemon
      ];

      pkgsInputs = inputs // {inherit pkgs-unstable;};

      mainPkgs =
        with builtins;
        (pkgs.callPackages ./notify-done pkgsInputs) 
        // listToAttrs (map mkPkgs packages);

      re-exports =
        with inputs';
        {
          sops-nix = sops-nix.packages.default;
          darktable-jpeg-sync = darktable-jpeg-sync.packages.default;
          lean-lsp-mcp = lean-lsp-mcp.packages.default;
          waybar = waybar.packages.default;
        }
        // {
          lspranto = lspranto.packages.default;
        };
    in
    {

      packages = mainPkgs // re-exports;
    };
}
