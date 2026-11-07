# Library of functions that need access to a nixpkgs instance in order to
# put things into the nix store.
#
# Instantiated once per flake evaluation with the flake's default nixpkgs
# (see extraArgs.nix) and exposed through `mlib`, so consumers never have to
# thread pkgs around: `mlib.readEncrypted ./some/git-crypt/file`.
#
# Note: reading a sanitized file during evaluation is import-from-derivation.
# This is unavoidable for this feature (builtins.readFile throws on binary
# content and the error is not catchable by tryEval), so the sanitizer is
# kept as cheap as possible: pure coreutils, no python, no dependencies.
# Results are cached in the store and only rebuilt when the source changes.
{
  pkgs,
  ...
}:
let
  # git-crypt encrypted files start with the magic header "\0GITCRYPT\0"
  gitCryptMagic = "00474954435259505400";

  sanitizeEncrypted =
    path:
    pkgs.runCommand "sanitized-${baseNameOf path}"
      {
        preferLocalBuild = true;
        allowSubstitutes = false;
      }
      ''
        if [ "$(od -An -tx1 -N10 ${path} | tr -d ' \n')" = "${gitCryptMagic}" ]; then
          # encrypted (repo locked): empty output
          : > $out
        else
          # plaintext (repo unlocked): pass through
          cp ${path} $out
        fi
      '';

  # Read a (potentially git-crypt encrypted) text file from nix.
  # Returns the file content when the repo is unlocked, and "" when it is
  # locked (i.e. when the file is binary ciphertext), so evaluation always
  # succeeds.
  readEncrypted = path: builtins.readFile (sanitizeEncrypted path);

  # Whether the git-crypt repository is currently locked, i.e. whether
  # encrypted files read as empty strings. Uses the canary file at
  # secrets/git-crypt-state (git-crypt encrypted, non-empty when unlocked).
  gitCryptLocked = readEncrypted ./secrets/git-crypt-state == "";
in
{
  inherit
    sanitizeEncrypted
    readEncrypted
    gitCryptLocked
    ;
}
