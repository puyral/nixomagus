{
  writeShellApplication,
  git,
  git-crypt,
  coreutils,
  ...
}:

writeShellApplication {
  name = "git-crypt-unlocker";

  runtimeInputs = [
    git-crypt
    git
    coreutils
  ];

  text = builtins.readFile ./script.sh;
}
