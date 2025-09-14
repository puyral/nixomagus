{
  lib,
  config,
  pkgs,
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
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          continue.continue
          vscodevim.vim
          rust-lang.rust-analyzer
          fill-labs.dependi
        ];
      };
    };
  };
}
