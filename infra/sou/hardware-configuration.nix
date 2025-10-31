{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  config = lib.mkMerge [
    {
      # copy bootloader from primary disk to redundant secondary
      boot.loader.systemd-boot.extraInstallCommands = ''
        ${lib.getExe pkgs.rsync} -a --delete /boot/. /boot2
      '';
    }
    (lib.mkIf (config.specialisation != { }) {
      fileSystems = {
        "/boot" = {
          device = "/dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_25143R801025-part1";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
        "/boot2" = {
          device = "/dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_25143R801032-part1";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
            "nofail"
          ];
        };
      };
    })
    {
      specialisation.secondary-efi.configuration = {

        fileSystems = {
          "/boot" = {
            device = "/dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_25143R801032-part1";
            fsType = "vfat";
            options = [
              "fmask=0022"
              "dmask=0022"
            ];
          };
          "/boot2" = {
            device = "/dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_25143R801025-part1";
            fsType = "vfat";
            options = [
              "fmask=0022"
              "dmask=0022"
              "nofail"
            ];
          };
        };
      };
    }
    {

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
          device = "root/root";
          fsType = "zfs";
          options = [ "zfsutil" ]; # removes need for dataset to have a legacy mountpoint
        };
        "/home" = {
          device = "root/home";
          fsType = "zfs";
          options = [ "zfsutil" ]; # removes need for dataset to have a legacy mountpoint
        };
        "/pool" = {
          device = "storagepool/pool";
          fsType = "zfs";
        };
        "/mnt/zfs/colossus" = {
          enable = true;
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
  ];
}
