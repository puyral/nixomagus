{ ... }:
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
  };
}
