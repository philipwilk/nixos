{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.flakeConfig.system.bootable.enable {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    hardware = {
      cpu = {
        amd = {
          updateMicrocode = true;
          sev.enable = true;
          sevGuest.enable = true;
        };
        intel = {
          updateMicrocode = true;
          sgx.provision.enable = true;
        };
      };
    };
    services.fwupd.enable = true;
  };
}
