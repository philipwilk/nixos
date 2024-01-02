{ pkgs, lib, ... }: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = lib.mkDefault "/boot/efi";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
