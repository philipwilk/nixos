{ pkgs
, ...
}: {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixowos";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-56963998-41a4-4ca6-afc9-a9eadb2b93c9".device = "/dev/disk/by-uuid/56963998-41a4-4ca6-afc9-a9eadb2b93c9";
  boot.initrd.luks.devices."luks-56963998-41a4-4ca6-afc9-a9eadb2b93c9".keyFile = "/crypto_keyfile.bin";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  hardware = {
    bluetooth.settings.General = {
      FastConnectable = true;
      ReconnectAttempts = 7;
      ReconnectIntervals = "1, 2, 3";
    };
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
}
