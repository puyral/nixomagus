{
  pkgs ? import <nixpkgs> { },
  pkgs-unstable ? import <nixpkgs> { },
  pkgs-stable ? import <nixpkgs> { },
}:
pkgs.mkShell {
  name = "config";
  buildInputs =
    (with pkgs-unstable; [ compose2nix ])
    ++ (with pkgs; [
      vim
      git
      git-crypt
      gh
      gnupg
    ])
    ++ (
      if pkgs.stdenv.isDarwin then
        [ ]
      else
        (with pkgs-unstable; [
          wev
          xorg.xev
          arandr
        ])
    );
}
