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
      sshBastion.enable = true;
      email.enable = true;
      harmonia.enable = true;
      mastodon.enable = true;
    };
    buildbot = {
      enableMaster = true;
      enableWorker = true;
    };
    # websites.fogbox.enable = true;
    nix.hercules-ci.enable = true;
  };

  networking = {
    hostName = "nixos-thinkcentre-tiny";
    firewall.interfaces."eno1".allowedTCPPorts = [
      80
      443
    ];
  };
}
