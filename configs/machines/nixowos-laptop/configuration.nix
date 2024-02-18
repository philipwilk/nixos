{ ...
}: {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixowos-laptop";
  hardware.sensor.iio.enable = true;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  services = {
    xserver.displayManager.autoLogin = {
      user = "philip";
      enable = true;
    };
  };
}
