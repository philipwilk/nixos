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

      linkConfig.MTUBytes = 1508;
    };
    "20-${linkNames.uplink}" = {
      matchConfig.Name = linkNames.uplink;
      # this line dont bloody work while pppoe is running
      #linkConfig.MTUBytes = 1508;
    };

  };

  # copied straight from s-n.me/building-a-nixos-router-for-a-uk-fttp-isp-the-basics
  # for the pppoe bollocks
  age.secrets.pppoe-chap = {
    file = ../../../../secrets/pppoe-chap.age;
    path = "/etc/ppp/chap-secrets";
    owner = "root";
    group = "root";
    mode = "0600";
  };

  services.pppd = {
    enable = true;
    peers.olilo.config = ''
      plugin pppoe.so ${linkNames.uplink}
      name "oli-wilk@olilo.net"

      noipdefault
      hide-password
      lcp-echo-interval 1
      lcp-echo-failure 4
      noauth
      persist
      maxfail 0
      holdoff 5
      mtu 1500
      mru 1500
      noaccomp
      default-asyncmap
      +ipv6
      ifname olilo-pppoe
    '';
  };

  systemd.services."pppd-olilo-pppoe".preStart = ''
    # if your ISP doesn't offer baby-jump frames, remove this line
    ${pkgs.iproute2}/bin/ip link set ${linkNames.uplink} mtu 1508
    # bring up the interface so ppp can use it
    ${pkgs.iproute2}/bin/ip link set ${linkNames.wan} up
  '';

  environment.etc.ppp-up = {
    enable = true;
    target = "ppp/ip-up";
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.logger}/bin/logger "$1 is up"
      if [ $IFNAME = "olilo-pppoe" ]; then
        ${pkgs.logger}/bin/logger "PPPoE online"

        ${pkgs.logger}/bin/logger "Add default routes via PPPoE"
        ${pkgs.iproute2}/bin/ip route add default dev olilo-pppoe scope link metric 100
      fi
    '';
  };

  environment.etc.ppp-down = {
    # this script runs after the PPP connection drops
    # we'll use it to log, and remove the default routes
    enable = true;
    target = "ppp/ip-down";
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.logger}/bin/logger "$1 is down"
      if [ $IFNAME = "olilo-pppoe" ]; then
        ${pkgs.logger}/bin/logger "PPPoE offline"

        ${pkgs.logger}/bin/logger "Remove default routes via PPPoE"
        ${pkgs.iproute2}/bin/ip route del default dev olilo-pppoe scope link metric 100

      fi
    '';
  };
  environment.etc.ppp-up-ipv6 = {
    enable = true;
    target = "ppp/ipv6-up";
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.logger}/bin/logger "$1 is up"
      if [ $IFNAME = "olilo-pppoe" ]; then
        ${pkgs.logger}/bin/logger "PPPoE online"

        ${pkgs.logger}/bin/logger "Add default routes via PPPoE"
        ${pkgs.iproute2}/bin/ip -6 route add default dev olilo-pppoe scope link metric 100
      fi
    '';
  };

  environment.etc.ppp-down-ipv6 = {
    # this script runs after the PPP connection drops
    # we'll use it to log, and remove the default routes
    enable = true;
    target = "ppp/ipv6-down";
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.logger}/bin/logger "$1 is down"
      if [ $IFNAME = "olilo-pppoe" ]; then
        ${pkgs.logger}/bin/logger "PPPoE offline"

        ${pkgs.logger}/bin/logger "Remove default routes via PPPoE"
        ${pkgs.iproute2}/bin/ip -6 route del default dev olilo-pppoe scope link metric 100

      fi
    '';
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
      devices.gateway = "olilo-pppoe";
    };
    services.nginx.enable = true;
  };
}
