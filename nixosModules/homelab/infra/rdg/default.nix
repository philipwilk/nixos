{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostId = "e9b36049";

  system.stateVersion = "25.11";

  homelab = {
    router = {
      enable = true;
      linkLocal = "fe80::66ab:5898:6981:3273";
      devices.wan = "enp131s0";
      devices.lan = "enp132s0";
    };
    services.nginx.enable = true;
  };
}
