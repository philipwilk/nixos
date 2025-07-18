{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = lib.mkMerge [
    /*
      {
        boot.loader.systemd-boot.extraInstallCommands = ''
          cp -n -a /boot/. /boot2
        '';
      }
    */
    (lib.mkIf (config.specialisation != { }) {
      fileSystems = {
        "/boot" = {
          device = "/dev/disk/by-uuid/0AD2-8339";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
        "/boot2" = {
          device = "/dev/disk/by-uuid/0A83-A084";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
            "nofail"
          ];
        };
      };
    })
    {
      specialisation.secondary-efi.configuration = {
        fileSystems = {
          "/boot" = {
            device = "/dev/disk/by-uuid/0A83-A084";
            fsType = "vfat";
            options = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
          "/boot2" = {
            device = "/dev/disk/by-uuid/0AD2-8339";
            fsType = "vfat";
            options = [
              "fmask=0077"
              "dmask=0077"
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
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "root/root";
        fsType = "zfs";
        options = [ "zfsutil" ];
      };

      fileSystems."/home" = {
        device = "root/home";
        fsType = "zfs";
        options = [ "zfsutil" ];
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    }
  ];
}
