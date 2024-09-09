{ config, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  homelab = {
    hostname = "rdg.uk.region.fogbox.uk";
    services = {
      nginx.enable = true;
    };
  };

  networking.hostName = "nixos-thinkcentre-tiny";
}
