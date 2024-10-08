{ custom, pkgs-unstable, ... }:
{
  imports = [ ];
  home = {
    packages = (with custom; [ vampire-master ]) ++ (with pkgs-unstable; [ elan ]);
  };
  services.gpg-agent.enable = true;
  programs.gnupg.agent.pinentryPackage =  pkgs.pinentry-curses;
}
