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
    pinentryPackage = pkgs.pinentry-tty;

  };
  # programs.gnupg.agent.pinentryPackage =  pkgs.pinentry-curses;
}
