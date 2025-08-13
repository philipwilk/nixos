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

  homelab = {
    hostname = config.networking.fqdn;
    router = {
      enable = true;
      linkLocal = "fe80::66ab:5898:6981:3273";
      devices.wanMac = "e8:ea:6a:93:e6:1d";
      devices.wan = "wan";
      devices.lanMac = "e8:ea:6a:93:e6:1e";
      devices.lan = "lan";
      devices.uplink = "vlan911";
    };
    services.nginx.enable = true;
    services.homeAssistant.enable = true;
  };

  homelab.services.kanidm = {
    enable = true;
    domain = "testing-idm.fogbox.uk";
    backupCount = 0;
  };
}
