{ ...
}: {
  imports = [ ./hardware-configuration.nix ];

  # Setup keyfile
  boot = {
    initrd.secrets = {
      "/crypto_keyfile.bin" = null;
    };
    kernelParams = [ "mem_sleep_default=deep" ];
  };
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
    tlp.enable = true;
    power-profiles-daemon.enable = false;
  };
}
