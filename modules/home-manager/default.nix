{
  lib,
  self,
  config,
  ...
}:
let
  base =
    { ... }:
    {
      options.extra = {
        nix.configDir =
          with lib;
          mkOption {
            type = types.path;
            default = "/config";
          };
      };
    };

  modules = {
    inherit base;
    alacritty = ./alacritty;
    applications = ./applications;
    btop = ./btop;
    darktable = ./darktable;
    emacs = ./emacs;
    firefox = ./firefox;
    git = ./git;
    git-config-fetcher = ./git-config-fetcher;
    hyprland = ./hyprland;
    i3 = ./i3;
    keyring = ./keyring;
    lazygit = ./lazygit;
    logseq = ./logseq;
    ntfy = ./ntfy;
    opencode = ./opencode;
    shell = ./shell;
    sops = ./sops;
    ssh = ./ssh;
    starship = ./starship;
    sway = ./sway;
    systemd-services = ./systemd-services;
    tmux = ./tmux;
    vscode = ./vscode;
    wallpaper = ./wallpaper;
    wandarr = ./wandarr;
    xkb = ./xkb;
    yazi = ./yazi;
    zsh = ./zsh;
  };

in
{
  options.modules.homeManager =
    with lib;
    mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "list of home manager modules to put in the `default` module";
    };

  config = {
    modules.homeManager = builtins.attrNames modules;

    flake.homeModules = modules // {
      default = (
        { ... }:
        {
          imports = map (n: self.homeModules.${n}) config.modules.homeManager;
        }
      );
    };
  };
}
