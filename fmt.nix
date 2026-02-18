{
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        settings.global.excludes = [
          ".git-crypt/*"
          ".gitattributes"
        ];
        programs.nixfmt.enable = true;
      };
    in
    {
      formatter = treefmtEval.config.build.wrapper;
    };
}
