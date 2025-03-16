{
  pkgs,
  lib,
  config,
  kmonad,
  ...
}:
let
  cfg = config.extra.keyboard;
in
{
  imports = [ kmonad.nixosModules.default ];
  options.extra.keyboard = {
    enable = lib.mkEnableOption "keyboard mods";
  };
  config = lib.mkIf cfg.enable {
    services.kmonad = {
      enable = true;
      package = pkgs.kmonad;
      keyboards = {
        hailuck = {
          device = "/dev/input/by-id/usb-HAILUCK_CO._LTD_USB_KEYBOARD-event-kbd";
          defcfg = {
            enable = true;
            fallthrough = true;
          };
          config = builtins.readFile ./hailuck.kbd;
        };
      };
    };
    services.xserver.xkb = {
      options = "compose:menu";
      layout = "us";
    };

    users.extraUsers.simon.extraGroups = [
      "input"
      "uinput"
    ];
  };
}
