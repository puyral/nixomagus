{ custom, ... }: {
  home.packages = [
    # cloocktui
    # (builtins.getFlake
    #   "github:puyral/clocktui?rev=950d9f909995553cdebfc35519a91c64189da3a2").packages.${system}.default

    custom.clocktui
  ];
}
