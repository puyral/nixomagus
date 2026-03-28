{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.firefox.nativeMessagingHosts = [ pkgs.gnome-browser-connector ];

  extra = {
    applications.gui = {
      enable = true;
      pinentry-qt = false;
    };
    logseq.enable = true;
    alacritty.enable = false;
  };

  home = {
    packages =
      [ ]
      ++ (with pkgs; [
        intel-gpu-tools
        nvtopPackages.intel
      ])
      ++ (with pkgs-unstable; [
        krita
        koreader
      ]);
    sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };
  };

}
