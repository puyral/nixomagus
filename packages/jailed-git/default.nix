{
  writeShellApplication,
  replaceVars,
  lib,
  git,
  gitName ? "puyral (llm)",
  gitEmail ? "ai@puyral.fr",
  ...
}:
{
  jailedGit = writeShellApplication {
    name = "git";
    bashOptions = [ "nounset" ];
    text = builtins.readFile (
      replaceVars ./git.sh {
        git = lib.getExe' git "git";
        inherit gitName gitEmail;
      }
    );
  };
}
