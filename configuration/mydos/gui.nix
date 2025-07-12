{ pkgs, ... }:

{
  extra.gui = {
    enable = true;
    gnome = true;
  };

  # Configure console keymap
  console.keyMap = "de";

  hardware.sensor.iio.enable = true;

  services.iptsd = {
    enable = true;
    config.Touchscreen = {
      DisableOnPalm = true;
    };
  };
  environment.systemPackages = with pkgs; [ iptsd ];
}
