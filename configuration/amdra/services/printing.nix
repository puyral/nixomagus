{ turboprint-nix, system, pkgs-self, ... }:
{
  imports = [ turboprint-nix.nixosModules.${system} ];

  services.turboprint.enable = true;

  environment.systemPackages = [ pkgs-self.turboprint ];
}
