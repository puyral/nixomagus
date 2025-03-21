{
  config,
  pkgs,
  lib,
  ...
}@attrs:
let
  my-hyprland = pkgs.hyprland;
  launcher = pkgs.writeShellScriptBin "hypr" ''
    #!/${pkgs.bash}/bin/bash
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only

    exec ${my-hyprland}/bin/Hyprland
  '';
  cfg = config.extra.hyprland;
in
{
  imports = [ ./options.nix ];
  config = lib.mkIf cfg.enable {
    # imports = [ ./wallpapers.nix ];

    home.packages = with pkgs; [
      wofi
      xdg-desktop-portal-hyprland
    ];

    home.file.".config/wofi.css".source = ./wofi.css;

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      # enableNvidiaPatches = true;

      settings = (import ./settings.nix attrs) // cfg.extraSettings;
    };
    programs.wpaperd.enable = true;
  };
}
