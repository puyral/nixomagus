{ pkgs, ... }:
{
  imports = [
    #  ../foreign-modules/kmonad/nix/nixos-module.nix 
  ];

  services.kmonad = {
    enable = true;
    package = pkgs.haskellPackages.kmonad;
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
}
