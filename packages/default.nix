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
          p = pkgs.callPackage file inputs;
        in
        {
          name = p.pname or p.name;
          value = p;
        };

      packages = [
        ./generate-jpgs
        ./paperless-ai
        ./rebuild
        ./swww-change-wp
        ./wandarr
        ./probe-rs-udev
        ./rnote
        ./isw
      ];

      sandbox = pkgs.callPackage ./sandbox {
        inherit (pkgs) replaceVars;
        microvmRunner = self.nixosConfigurations.sandbox.config.microvm.runner.qemu;
      };

      csandbox = pkgs.callPackage ./csandbox {
        inherit (pkgs) replaceVars systemd;
        csandboxSystem = self.nixosConfigurations.csandbox.config.system.build.toplevel;
      };

      mainPkgs =
        with builtins;
        (pkgs.callPackages ./notify-done inputs) // listToAttrs (map mkPkgs packages) // { inherit sandbox csandbox; };

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
