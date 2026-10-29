{ pkgs-unstable, ... }:
{
  imports = [
    # ./printing.nix
  ];

  extra = {
    smartd = {
      enable = true;
      disks = [
        # 10TB toshiba
        "wwn-0x5000039b38d17cf2"
      ];
    };

    llm.enable = false;
    pi-ops-redirect = {
      enable = true;
      # amdra has no systemd-resolved (WARP owns /etc/resolv.conf), so the
      # 127.0.0.53 stub is dead and `sandbox.local` is mDNS-only (unresolvable
      # by nginx's unicast resolver). Use the Incus bridge DNS to resolve the
      # local sandbox VM by its stable instance name instead.
      resolver = "10.146.96.1";
      backend = "nixos-sandbox";
    };

    incus.enable = true;
    acme.enable = true;
  };
  services.ollama.package = pkgs-unstable.ollama-rocm;
  networking.nginx.enable = true;
}
