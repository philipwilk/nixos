{
	pkgs,
	...
}:
{
	virtualisation.vmVariant = {
		virtualisation = {
			memorySize = 16384;
			cores = 8;
		};
	};
	
  networking = {
    hostName = "nixosvmtest";
    networkmanager.enable = true;
  };
	
  security.rtkit.enable = true;

	users.users.nixosvmtest = {
		isNormalUser = true;
		password = "test";
    extraGroups = [
			"wheel"
		];
		group = "nixosvmtest";
	};
	users.groups.nixosvmtest = {};

	services.openssh = {
		enable = true;
	};
	
	boot.kernelPackages = pkgs.linuxPackages_latest;

	nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
