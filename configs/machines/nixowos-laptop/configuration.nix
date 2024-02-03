{ ...
}: {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixowos-laptop";
  hardware.sensor.iio.enable = true;
}
