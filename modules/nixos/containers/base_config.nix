{
  c_config ? {
    vpn = false;
  },
  overlays,
  ...
}:
{ pkgs, lib, ... }:
{

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    htop
    git
    tmux
    iptables
  ];

  networking = {
    firewall.enable = false;
    # Use systemd-resolved inside the container
    # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
    useHostResolvConf = lib.mkForce false;
  };
  services.resolved.enable = true;

  services.openssh = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = overlays;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.tailscale = {
    enable = c_config.vpn;
    openFirewall = true;
    # useRoutingFeatures = "server";
  };
}
