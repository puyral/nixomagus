{pkgs, ...}:{
	boot.initrd.kernelModules = ["amdgpu"];
	boot.kernelParams = ["radeon.cik_support=0" "amdgpu.cik_support=1"];
	
	hardware.oopengel.extraPackages = [
		pkgs.mesa.opencl
	];
}
