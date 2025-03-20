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

  text = import ./script.sh;
}
