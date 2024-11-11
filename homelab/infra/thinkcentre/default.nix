{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostId = "d60c7b2e";
  networking.hostName = "thinkcentre";
  system.stateVersion = "24.11"; # Did you read the comment?

  homelab = {
    hostname = "rdg.uk.region.fogbox.uk";
    net.lan = "eno1";
    services.nginx.enable = true;
    services.email.enable = true;
  };
}
