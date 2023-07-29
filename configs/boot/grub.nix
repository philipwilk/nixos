{ pkgs, ... }: {
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
