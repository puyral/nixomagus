{
  homeManagerModules = rec {
    default = ./default.nix;

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
}
