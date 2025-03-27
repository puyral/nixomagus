{ pkgs, ... }:
{
  imports = [
    ./zfs.nix
    # ../commun/filesystem.nix
  ];
  fileSystems =
    let
      pool = "DynasRoot";
      mkZfs = name: {
        device = "${pool}${name}";
        fsType = "zfs";
      };

      fs =
        mounts:
        with builtins;
        listToAttrs (
          map (name: {
            inherit name;
            value = mkZfs name;
          }) mounts
        );

    in
    (
      {
        "/boot" = {
          device = "/dev/disk/by-label/NIXBOOT";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
        "/" = {
          device = pool;
          fsType = "zfs";
        };
      }
      // fs [
        "/nix"
        "/home"
        "/var"
        "/containers"
        "/config"
      ]
    );

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      extraPools = [ "DynasRoot" ];
      forceImportRoot = true; # whatever you, do boot

    };
    tmp = {
      useTmpfs = true;
    };

  };
  swapDevices = [ ];
}
