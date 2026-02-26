{
  lib,
  config,
  pkgs,
  pkgs-self,
  ...
}:
let
  cfg = config.extra.emacs;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      extraPackages =
        epkgs:
        with epkgs;
        [
          pkgs-self.proof-general-with-squirrel
          evil
        ]
        ++ cfg.extensions;
      extraConfig = builtins.readFile ./init.el;
    };

    home.packages = [ ] ++ lib.optional cfg.squirrel.enable pkgs-self.squirrel;
  };
}
