{
  writeShellApplication,
  git,
  git-crypt,
  coreutils,
  inetutils,
  replaceVars,
  flakePath ? "/config",
  type ? "nixos",
  name ? "simon",
  ...
}:
writeShellApplication {
  name = "rebuild";
  runtimeInputs = [
    git
    git-crypt
    coreutils
    inetutils
  ];
  text = builtins.readFile (
    replaceVars ./script.sh {
      inherit flakePath type name;
    }
  );
}
