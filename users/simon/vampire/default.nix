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
            vampire
            z3
            clang
          ]
        );
      in
      (with pkgs-unstable; [ elan ]) ++ rust;

  };
  programs.zsh.sessionVariables = (
    with pkgs-unstable;
    {
      RUST_SRC_PATH = "${pkgs-unstable.rustPlatform.rustLibSrc}";
      LIBCLANG_PATH = "${clang.cc.lib}/lib";
      BINDGEN_EXTRA_CLANG_ARGS = "\$(< ${clang}/nix-support/cc-cflags) \$(< ${clang}/nix-support/libc-cflags) \$(< ${clang}/nix-support/libcxx-cxxflags)";
    }
  );
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;

  };
  extra.shell.rebuildScript = ./rebuild.sh;
  # programs.gnupg.agent.pinentryPackage =  pkgs.pinentry-curses;
}
