{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "prime";

  users.users.philip.packages = with pkgs; [ xivlauncher ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
}
