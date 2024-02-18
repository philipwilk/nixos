# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      luks.devices = {
        # LUKS root
        "luks-2c091ef5-7caa-496c-aa43-7a85d4378ec0".device = "/dev/disk/by-uuid/2c091ef5-7caa-496c-aa43-7a85d4378ec0";
        # LUKS swapfile
        "luks-ad203aa1-6766-4952-b43a-08478b322dfa".device = "/dev/disk/by-uuid/ad203aa1-6766-4952-b43a-08478b322dfa";
      };
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "mem_sleep_default=deep" "i915.enable_guc=3" "i915.enable_fbc=1" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/53b733fc-9124-47a3-82cc-f33541bedb0f";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/F4D5-689D";
      fsType = "vfat";
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/6e00a92b-15ac-4af0-8ad2-8784425a5bee"; }];
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp109s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
