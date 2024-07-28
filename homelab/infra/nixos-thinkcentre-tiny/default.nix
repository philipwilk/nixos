{ config, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  homelab = {
    isLeader = true;
    services = {
      nginx.enable = true;
      nextcloud = {
        enable = true;
        domain = "nextcloud.philipw.uk";
      };
      navidrome.enable = true;
      factorio = {
        enable = true;
        admins = [ "wiryfuture" ];
      };
      openldap.enable = true;
      uptime-kuma.enable = true;
      vaultwarden.enable = true;
      mediawiki = {
        enable = true;
        name = "Reading CS lore";
        domain = "lore.fogbox.uk";
      };
      email.enable = true;
      harmonia.enable = true;
      mastodon.enable = true;
      #forgejo.enable = true;
      soft-serve.enable = true;
      searxng.enable = true;
    };
    buildbot = {
      enableMaster = true;
      enableWorker = true;
    };
    # websites.fogbox.enable = true;
    nix.hercules-ci.enable = true;
  };

  services.openssh.ports = [ 22420 ];

  networking = {
    hostName = "nixos-thinkcentre-tiny";
    firewall.interfaces."eno1".allowedTCPPorts = [
      80
      443
    ];
  };
}
