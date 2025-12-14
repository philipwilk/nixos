{
  config,
  lib,
  pkgs,
  ...
}:
let
  linkNames = config.homelab.router.devices;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostId = "e9b36049";

  system.stateVersion = "25.11";

  systemd.network.wait-online.enable = false;
  systemd.network.links = {
    "90-${linkNames.wan}" = {
      matchConfig.PermanentMACAddress = config.homelab.router.devices.wanMac;
      linkConfig = {
        Name = linkNames.wan;
      };
    };
    "90-${linkNames.lan}" = {
      matchConfig.PermanentMACAddress = config.homelab.router.devices.lanMac;
      linkConfig = {
        Name = linkNames.lan;
      };
    };
  };

  systemd.network.netdevs = {
    "0-${linkNames.uplink}" = {
      netdevConfig = {
        Kind = "vlan";
        Name = linkNames.uplink;
      };
      vlanConfig.Id = 911;
    };
  };

  systemd.network.networks = {
    "10-${linkNames.wan}" = {
      matchConfig.PermanentMACAddress = config.homelab.router.devices.wanMac;
      vlan = [
        linkNames.uplink
      ];
    };
  };

  networking.domains = {
    enable = true;
    baseDomains.${config.homelab.tld} = { };
    subDomains = {
      ${config.networking.fqdn} = {
        a.data = "158.173.146.38";
        aaaa.data = "2a11:2646:1005:1:eaea:6aff:fe93:e61d";
      };
    };
  };

  homelab = {
    hostname = config.networking.fqdn;
    net.lan = config.homelab.router.devices.lan;
    router = {
      enable = true;
      linkLocal = "fe80::66ab:5898:6981:3273";
      devices.wanMac = "e8:ea:6a:93:e6:1d";
      devices.wan = "wan";
      devices.lanMac = "e8:ea:6a:93:e6:1e";
      devices.lan = "lan";
      devices.uplink = "vlan911";
      systemd.enableCake = true;
      systemd.cakeBandwidth = "2100";
    };
    services.nginx.enable = true;
    services.homeAssistant.enable = true;
  };

  homelab.services.kanidm = {
    enable = true;
    domain = "testing-idm.fogbox.uk";
    backupPath = "/var/lib/kanidm/backups";
  };

  homelab.buildbot.enableWorker = true;
  services.buildbot-nix.worker.masterUrl = "tcp:host=buildbot.fogbox.uk:port=9989";

  homelab.ci.runners.gitlab.csgitlab.enabled = true;
  homelab.ci.runners.gitlab.csgitlab.secretPath = ../../secrets/runners/csgitlab/rdg.age;

  homelab.games.factorio = {
    # Needs statedir option fix /var/lib/factorio
    enable = true;
    admins = [ "wiryfuture" ];
  };

  services.factorio.saveName = "buk2";
}
