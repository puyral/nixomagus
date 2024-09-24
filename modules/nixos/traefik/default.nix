{ config, ... }:
{
  imports =
    [ ./module.nix ]
    ++ (
      if config.networking.traefik.enable then
        [
          ./service.nix

        ]
      else
        [ ]
    );

}
