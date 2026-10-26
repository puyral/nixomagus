{ lib, computer, ... }: {
  options.extra.pi-ops-redirect = with lib; {
    enable = mkEnableOption "redirect to pi-ops";
    subdomain = mkOption {
      description = "pi.<subdomain>.puyral.fr";
      type = types.str;
      default = "${computer.name}";
    };
  };
}
