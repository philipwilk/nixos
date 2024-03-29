{ pkgs, ... }: {
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
