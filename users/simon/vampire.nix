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
          ]
        );
      in
      (with custom; [ vampire-master ]) ++ (with pkgs-unstable; [ elan ]) ++ rust;
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;

  };
  # programs.gnupg.agent.pinentryPackage =  pkgs.pinentry-curses;
}
