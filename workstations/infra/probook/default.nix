{ pkgs, config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "probook";
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vaapiVdpau
    libvdpau-va-gl
  ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.thermald.enable = true;

  age.secrets.probookPriv.file = ../../../secrets/wireguard/probook/private.age;
  homelab.networking.wireguard.enable = false;
  networking.wireguard.interfaces.wg0 = {
    privateKeyFile = config.age.secrets.probookPriv.path;
    ips = [
      "10.100.0.2/24"
      "fd42:42:42::2/64"
    ];
  };
}
