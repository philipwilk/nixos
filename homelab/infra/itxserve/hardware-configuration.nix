{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "newroot/root";
      fsType = "zfs";
      options = [ "zfsutil" ]; # removes need for dataset to have a legacy mountpoint
    };
    "/home" = {
      device = "newroot/home";
      fsType = "zfs";
      options = [ "zfsutil" ]; # removes need for dataset to have a legacy mountpoint
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8D51-74E2";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/pool" = {
      device = "storagepool/pool";
      fsType = "zfs";
    };
    "/mnt/zfs/colossus" = {
      enable = false;
      device = "colossus/root";
      fsType = "zfs";
      options = [ "zfsutil" ]; # removes need for dataset to have a legacy mountpoint
    };
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
