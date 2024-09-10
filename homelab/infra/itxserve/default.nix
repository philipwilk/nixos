{ config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "itxserve"; # Define your hostname.
  networking.hostId = "9e09d7d7"; # needed for zfs

  system.stateVersion = "24.11"; # Did you read the comment?

  homelab = {
    hostname = "sou.uk.region.fogbox.uk";
    isLeader = true;
    stateDir = "/pool";
    router.enable = true;
    services = {
      nginx.enable = true;
      nextcloud = {
        enable = true;
        domain = "cloud.${config.homelab.tld}";
      };
      navidrome.enable = true;
      openldap.enable = true; # needs stateDir fix
      vaultwarden.enable = true; # needs stateDir fix, /var/lib/vaultwarden
      mediawiki = { # needs statedir fix
        enable = true;
        name = "Reading CS lore";
        domain = "lore.fogbox.uk";
      };
      uptime-kuma.enable = true;
      email.enable = true;
      mastodon.enable = true; # needs stateDir fix
      soft-serve.enable = true; #needs stateDir fix

      searxng.enable = true;
    };
    games = {
      # Needs statedir option fix /var/lib/factorio
      #factorio = {
      #  enable = true;
      #  admins = [ "wiryfuture" ];
      #};
    };
    nix = {
      hercules-ci.enable = true;
      harmonia.enable = true;
    };
  };
}
