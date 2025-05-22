{ pkgs, lib, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = lib.mkDefault (
      pkgs.linuxPackagesFor (
        pkgs.linuxKernel.kernels.linux_6_14.override {
          argsOverride = rec {
            src = pkgs.fetchurl {
              url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
              hash = "sha256-KCB+xSu+qjUHAQrv+UT0QvfZ8isoa3nK9F7G3xsk9Ak=";
            };
            version = "6.14.5";
            modDirVersion = "6.14.5";
          };
        }
      )
    );
  };
}
