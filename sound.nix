
{ config, lib, pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;

    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable =true;
    alsa.support32Bit = true;
    jack.enable = true;


  };
  hardware.pulseaudio.enable = false;
}