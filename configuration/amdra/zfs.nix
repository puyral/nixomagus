{
  config,
  rootDir,
  lib,
  ...
}:
let
  zfsAttribute = config.boot.zfs.package.kernelModuleAttribute;
  zfgsmodule = config.vars.kernel.${zfsAttribute};
  enabled = !zfgsmodule.meta.broken;

in
{
  boot = lib.mkIf enabled {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      extraPools = [ "Backup" ];
      forceImportRoot = false;
    };
    kernel.sysctl = {
      # "vfs.zfs.l2arc_rebuild_enabled" = 1;
      "vfs.zfs.arc_max" = "1073741824";
    };
  };
  networking.hostId = "007f0201";
}
