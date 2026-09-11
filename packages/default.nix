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
        ./mango
        ./gzip-bomb
        ./tea-transfer
        ./print-path
      ];

      pkgsInputs = inputs // {
        inherit pkgs-unstable inputs';
      };

      mainPkgs =
        with builtins;
        (pkgs.callPackages ./notify-done pkgsInputs) // listToAttrs (map mkPkgs packages);

      re-exports =
        with inputs';
        with builtins;
        let
          mkReexport = n: inputs'."${n}".packages.default;
          mkReexports =
            l:
            listToAttrs (
              map (name: {
                inherit name;
                value = mkReexport name;
              }) l
            );
        in
        (mkReexports [
          "sops-nix"
          "darktable-jpeg-sync"
          "lean-lsp-mcp"
          "waybar"
          "lspranto"
          "pi-subagent-control"
        ])
        // (with inputs'."audio.cpp".packages; {
          audio-cpp-cpu = cpu;
          audio-cpp-vulkan = vulkan;
          audio-cpp-amd = rocm;
        });
    in
    {

      packages = mainPkgs // re-exports;
    };
}
