{ lib, ... }:
let
  bootPARTUUID = "40afad1f-7f41-49f5-81cb-50bf7d61b307";
  boot2PARTUUID = "d5259cdb-6741-46cf-a928-8292a9189e7a";
  poolName = "DynasOs";
in
{
  imports = [
    ./zfs.nix
  ];
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partuuid/${bootPARTUUID}";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/boot2" = {
      device = "/dev/disk/by-partuuid/${boot2PARTUUID}";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/" = {
      device = "${poolName}/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "${poolName}/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "${poolName}/home";
      fsType = "zfs";
    };
    "/var/lib/docker" = {
      # DynasOs/docker
      device = "${poolName}/docker";
      fsType = "zfs";
    };
  };
  swapDevices = [ ];

  virtualisation.docker.storageDriver = "zfs";

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      extraPools = [ poolName ];
      forceImportRoot = true;
    };

    tmp = {
      useTmpfs = true;
      tmpfsSize = lib.mkDefault "50%";
    };
  };
  vars.poolName = poolName;
}
