{ config, lib, pkgs, modulesPath, ... }:
{

  fileSystems = {
	  "/mnt/btrfs-root" =
	    { device = "/dev/disk/by-label/NIXROOT";
	      fsType = "btrfs";
	    };

	    "/" =
	    { device = "/dev/disk/by-label/NIXROOT";
	      fsType = "btrfs";
	      options = [ "subvol=root" "compress=zstd"];
	    };

	  "/home" =
	    { device = "/dev/disk/by-label/NIXROOT";
	      fsType = "btrfs";
	      options = [ "subvol=home" "compress=zstd"];
	    };

	  "/Volumes/Zeno/media/photos" =
	    { device = "/dev/disk/by-label/NIXROOT";
	      fsType = "btrfs";
	      options = [ "subvol=photos" "compress=zstd"];
	    };

	  "/nix" =
	    { device = "/dev/disk/by-label/NIXROOT";
	      fsType = "btrfs";
	      options = [ "subvol=nix" "compress=zstd" "noatime"];
	    };

	  "/config" =
	    { #device = "/dev/disk/by-label/NIXROOT";
              label = "NIXROOT";
	      fsType = "btrfs";
	      options = [ "subvol=config" "compress=zlib"];
	    };

	  "/boot" =
	    { device = "/dev/disk/by-label/ESP";
	      fsType = "vfat";
	    };
	  
	  "/mnt/Windows" =
	    { device = "/dev/sda3";
	      fsType = "ntfs-3g"; 
	      options = [ "rw" "uid=1000"];
	    };
	  
	  "/mnt/Zeno" =
	    { device = "192.168.0.2:/mnt/Zeno";
	      fsType = "nfs"; 
	      options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
	    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];
  boot.supportedFilesystems = [ "ntfs" ];
 # see https://discourse.nixos.org/t/nixos-install-with-custom-flake-results-in-boot-being-world-accessible/34555/3
}
