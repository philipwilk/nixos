# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config
, lib
, pkgs
, modulesPath
, ...
}: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/d0a8b583-58ce-44d9-a94e-58a806fee3ec";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-02a8e4f1-370a-4bed-ba04-7d7950dbe564".device = "/dev/disk/by-uuid/02a8e4f1-370a-4bed-ba04-7d7950dbe564";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/E8BC-1121";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/82815d0e-3e57-4c55-adad-d8373cebbd0f"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp10s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
