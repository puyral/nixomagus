{
  pkgs ? import <nixpkgs> { },
  pkgs-unstable ? import <nixpkgs> { },
  pkgs-stable ? import <nixpkgs> { },
  sops-nix ? pkgs.sops,
  ...
}:
pkgs.mkShell {
  name = "config";
  buildInputs =
    (with pkgs; [
      vim
      gitFull
      gh
      gnupg
      sops
      git-crypt
      sops-nix
    ])
    ++ (
      if pkgs.stdenv.isDarwin then
        [ ]
      else
        (with pkgs; [
          wev
          xorg.xev
          arandr
        ])
    );
}
