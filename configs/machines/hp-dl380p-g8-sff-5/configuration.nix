{ ... }:

{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "hp-dl380p-g8-sff-5";
  homelab.enable = true;
}
