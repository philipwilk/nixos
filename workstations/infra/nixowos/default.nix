{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixowos";

  users.users.philip.packages = with pkgs; [ xivlauncher ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
}
