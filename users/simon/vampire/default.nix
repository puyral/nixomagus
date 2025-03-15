{
  custom,
  pkgs-unstable,
  pkgs,
  ...
}:
{
  imports = [ ];
  home = {
    packages =
      let
        rust = (
          with pkgs-unstable;
          [
            cargo
            clippy
            cargo-expand
            rust-analyzer
            rustc
            rustfmt
            gcc
          ]
        );
      in
      (with pkgs-unstable; [ elan ]) ++ rust;

  };
  programs.zsh.sessionVariables = {
    RUST_SRC_PATH = "${pkgs-unstable.rustPlatform.rustLibSrc}";
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;

  };
  # programs.gnupg.agent.pinentryPackage =  pkgs.pinentry-curses;
}
