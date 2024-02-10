
{ config, lib, pkgs, ... }:
{
  services.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;

    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable =true;
    alsa.support32Bit = true;
    jack = true;


  };
}