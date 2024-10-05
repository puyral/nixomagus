# https://wiki.nixos.org/wiki/Plymouth
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.extra.splash_screen;
in
{
  options.extra.splash_screen = {
    enable = lib.mkEnableOption "splash screen";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "rings";
      description = "a splash screen";
    };
  };

  config.boot = lib.mkIf cfg.enable {

    # see https://github.com/adi1090x/plymouth-themes?tab=readme-ov-file for themes
    plymouth = {
      enable = true;
      theme = cfg.theme;
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override { selected_themes = [ cfg.theme ]; })
      ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 3;
  };
}
