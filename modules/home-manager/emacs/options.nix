{ lib, config, ... }:
{
  options.extra.emacs = with lib; {
    enable = mkEnableOption "emacs";

    nox = mkOption {
      type = types.bool;
      default = config.extra.gui.enable;
      description = "wethere to add X support for emacs.";
    };

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
