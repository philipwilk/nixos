{ lib, ... }:
{
  boot = {
    kernelParams = [ "mem_sleep_default=deep" ];
    initrd = {
      systemd.enable = true;
      availableKernelModules = [
        "aesni_intel"
        "cryptd"
      ];
    };
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
