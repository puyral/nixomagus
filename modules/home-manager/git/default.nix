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
      lfs.enable = true;
      settings = {
        user = {
          name = "puyral";
          email = "github@puyral.fr";
          signingkey = "1E96E80F8B44B1242EB2645A2F89AA8206299121";
        };
        safe.directory = location;
        submodule.recurse = true;
        diff.submodule = "log";
        status.submoduleSummary = true;
      };
    };
    programs.gh = {
      enable = false;
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
