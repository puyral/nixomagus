{ lib, ... }:
{
  options.extra.emacs = with lib; {
    enable = mkEnableOption "emacs";

    extensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional emacs packages from nixpkgs";
    };

    squirrel = {
      enable = mkEnableOption "squirrel prover emacs integration";
    };
  };
}
