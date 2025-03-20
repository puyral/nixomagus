{pkgs, ...}:{
  extra.github-runners = {
      enable = true;
      runners = {
        auto-config = 
        let git-crypt-unlocker = pkgs.callPackages ./git-crypt-unlocker.nix {}; in
        {
          enable = true;
          url = "https://github.com/puyral/nixomagus";
          tokenFile = ./secrets/auto-config-tocken;
          name = "dynas";
          extraPackages = [git-crypt-unlocker];
        };
      };
    };
}