{ pkgs-self, ... }:
{
  pkgs-unstable = [
    (final: prev: {
      darktable = pkgs-self.darktable;
    })
  ];
  pkgs = [
    (final: prev: {
      darktable = pkgs-self.darktable;
    })
  ];
}
