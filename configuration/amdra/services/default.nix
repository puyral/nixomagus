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
    pi-ops-redirect.enable = true;

    incus.enable = true;
    acme.enable = true;
  };
  services.ollama.package = pkgs-unstable.ollama-rocm;

}
