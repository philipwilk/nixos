{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  users.users.philip.packages = with pkgs; [ xivlauncher ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
}
