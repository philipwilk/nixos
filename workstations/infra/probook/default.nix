{ pkgs, config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vaapiVdpau
    libvdpau-va-gl
  ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.thermald.enable = true;
}
