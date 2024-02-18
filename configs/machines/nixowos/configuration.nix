{ pkgs
, ...
}: {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixowos";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
}
