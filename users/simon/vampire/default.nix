{
  config,
  custom,
  pkgs-unstable,
  pkgs,
  lib,
  rust-overlay,
  ...
}:
let
  rustPkgs = pkgs-unstable.extend rust-overlay.overlays.default;
in
{
  imports = [ ];
  home = {

    packages =
      let
        rust = (
          with rustPkgs;
          [
            cargo-expand
            cargo-limit
            rust-bin.stable.latest.complete
          ]
        );
      in
      (with pkgs-unstable; [ elan ])
      ++ (with pkgs; [
        vampire
        z3
        clang
      ])
      ++ rust;

  };
  programs.zsh.sessionVariables = (
    with rustPkgs;
    {
      #RUST_SRC_PATH = "${pkgs-unstable.rustPlatform.rustLibSrc}";
      LIBCLANG_PATH = "${clang.cc.lib}/lib";
      BINDGEN_EXTRA_CLANG_ARGS = "\$(< ${clang}/nix-support/cc-cflags) \$(< ${clang}/nix-support/libc-cflags) \$(< ${clang}/nix-support/libcxx-cxxflags)";
    }
  );
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
  };
  extra = {
    nix.configDir = "/home/simon/.config/home-manager";
    shell.rebuild = {
      type = "home-manager";
    };
    opencode = {
      enable = true;
      leanSupport.mcp = true;
    };
    emacs.enable = true;
  };

  programs.git.settings = {
    user.name = lib.mkForce "Simon Jeanteur";
    user.email = lib.mkForce "simon.jeanteur@tuwien.ac.at";
  };

  programs.ssh.matchBlocks."gitlab.secpriv.tuwien.ac.at" = lib.mkForce { };
  # programs.gnupg.agent.pinentryPackage =  pkgs.pinentry-curses;
}
