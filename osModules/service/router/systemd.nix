{ config, lib, ... }:
let
  r = config.homelab.router;
  routerIp = r.ip4;
  linkLocal = r.linkLocal;

  cfg = config.homelab.router.systemd;
  lan = config.homelab.router.devices.lan;
  wan = config.homelab.router.devices.wan;
  uplink = config.homelab.router.devices.uplink;
  gateway = config.homelab.router.devices.gateway;

  dns4 = routerIp;
  dns6 = linkLocal;
in
{
  options.homelab.router.systemd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.homelab.router.enable;
      example = true;
      description = ''
        Whether to enable systemd network configuration.
      '';
    };
    ipRange = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.0/16";
      example = "192.168.1.0/24";
      description = ''
        IP4 address range to use for the lan
      '';
    };
    cakeBandwidth = lib.mkOption {
      type = lib.types.str;
      default = "850";
      example = "2250";
      description = ''
        Max bandwidth for CAKE qdisc, in megabits
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    systemd.network = {
      enable = true;
      config.networkConfig.IPv6Forwarding = "yes";
      networks = {
        # only configure in simple ethernet dhcp network - no custom gateway set (pppoe)
        # (uplink allows for simple ethernet dhcp with vlan)
        "10-${uplink}" = lib.mkIf (uplink == gateway) {
          matchConfig.Name = uplink;
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = "yes";
            DHCPPrefixDelegation = "yes";
            LinkLocalAddressing = "ipv6";
            IPv4Forwarding = "yes";
          };

          dhcpV4Config = {
            UseHostname = "no";
            UseDNS = "no";
            UseNTP = "no";
            UseSIP = "no";
            UseRoutes = "no";
            UseGateway = "yes";
          };

          ipv6AcceptRAConfig = {
            UseDNS = "no";
            DHCPv6Client = "yes";
          };

          dhcpPrefixDelegationConfig.UplinkInterface = ":self";

          dhcpV6Config = {
            WithoutRA = "solicit";
            UseHostname = "no";
            UseDNS = "no";
            UseNTP = "no";
          };

          cakeConfig = {
            Bandwidth = "${cfg.cakeBandwidth}M";
            OverheadBytes = 48;
            MPUBytes = 84;
            CompensationMode = "none";
            FlowIsolationMode = "triple";
            PriorityQueueingPreset = "diffserv8";
          };

          linkConfig.RequiredForOnline = "no";
        };
        "15-${lan}" = {
          matchConfig.Name = lan;
          matchConfig.Type = "ether";
          networkConfig = {
            IPv6AcceptRA = "no";
            IPv6SendRA = "yes";
            LinkLocalAddressing = "ipv6";
            DHCPPrefixDelegation = "yes";
            DHCPServer = "yes";
            Address = "${routerIp}/16";
            IPv4Forwarding = "yes";
            IPMasquerade = "ipv4";
          };

          dhcpServerConfig = {
            EmitRouter = "yes";
            EmitDNS = "yes";
            DNS = dns4;
            EmitNTP = "yes";
            NTP = routerIp;
            PoolOffset = 100;
            ServerAddress = "${routerIp}/16";
            UplinkInterface = config.homelab.router.devices.uplink;
            DefaultLeaseTimeSec = 1800;
          };

          dhcpServerStaticLeases = [
            # {
            #   # Idac for example
            #   Address = "192.168.1.50";
            #   MACAddress = "54:9f:35:14:57:3e";
            # }
          ];

          linkConfig.RequiredForOnline = "yes";

          ipv6SendRAConfig = {
            EmitDNS = "yes";
            DNS = dns6;
            EmitDomains = "no";
          };

          dhcpPrefixDelegationConfig.UplinkInterface = uplink;
        };
      };
    };

    # Open ports for dhcp server on lan
    networking.firewall.interfaces.${lan}.allowedUDPPorts = [
      67
      68
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
      636
      389
      25
      465
      993
      22420
      22
      34197
    ];
  };
}
