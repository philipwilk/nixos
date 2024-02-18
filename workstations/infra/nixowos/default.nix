{ pkgs
, ...
}: {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixowos";

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
}
