{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.extra.git;
  location = config.extra.nix.configDir;
in
{
  options.extra.git = {
    enable = lib.mkEnableOption "git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user = {
          name = "puyral";
          email = "7871851+puyral@users.noreply.github.com";
          signingkey = "1E96E80F8B44B1242EB2645A2F89AA8206299121";
        };
        safe.directory = location;
      };
    };
    programs.gh = {
      enable = true;
      hosts = {
        "github.com" = {
          git_protocol = "ssh";
          users = [ "puyral" ];
          user = "puyral";
        };
      };
    };
  };
}
