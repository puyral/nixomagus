{ system, pkgs, ... }: {
  home.packages = [
    # cloocktui
    (builtins.getFlake
      "github:puyral/clocktui?rev=950d9f909995553cdebfc35519a91c64189da3a2").packages.${system}.default

    (pkgs.writeShellScriptBin "hypr" ''
      #!/${pkgs.bash}/bin/bash
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only

      exec ${pkgs.jellyfin-desktop}/bin/Hyprland
    '')
  ];
}
