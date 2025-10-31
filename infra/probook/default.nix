{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../osModules/classes/personalDevice
  ];

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vaapiVdpau
    libvdpau-va-gl
  ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  flakeConfig.environment.declarativeHome.enable = true;

  services = {
    fprintd.enable = true;
    pcscd.enable = true;
  };

  services.thermald.enable = true;

  system.stateVersion = "23.05";
}
