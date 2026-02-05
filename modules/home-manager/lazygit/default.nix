{
  lib,
  config,
  ...
}:
let
  cfg = config.extra.lazygit;
in
{
  options.extra.lazygit = with lib; {
    enable = mkEnableOption "lazygit";
  };

  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
    };

    home.shellAliases = {
      lz = "lazygit";
    };
  };
}
