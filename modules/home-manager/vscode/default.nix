{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.extra.vscode;
in
{
  options.extra.vscode = with lib; {
    enable = mkEnableOption "vscode";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs-unstable.vscode;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          # ncontinue.continue
          #vscodevim.vim
          #rust-lang.rust-analyzer
          #fill-labs.dependi
        ];
      };
    };
  };
}
