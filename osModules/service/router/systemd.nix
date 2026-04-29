{ config, lib, ... }:
let
  r = config.homelab.router;
  routerIp = r.ip4;
  linkLocal = r.linkLocal;

  cfg = config.homelab.router.systemd;
  devices = config.homelab.router.devices;
  lan = config.homelab.router.devices.lan;
  uplink = config.homelab.router.devices.uplink;

  dns4 = routerIp;
  dns6 = linkLocal;

  generateUplinkConfiguration = uplinkName: routeMetric: {
    matchConfig.Name = uplinkName;
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
      RouteMetric = routeMetric;
    };

    ipv6AcceptRAConfig = {
      UseDNS = "no";
      DHCPv6Client = "yes";
      UseGateway = "yes";
      RouteMetric = routeMetric;
    };

    dhcpPrefixDelegationConfig.UplinkInterface = ":self";

    dhcpV6Config = {
      WithoutRA = "solicit";
      UseHostname = "no";
      UseDNS = "no";
      UseNTP = "no";
    };

    cakeConfig = lib.mkIf cfg.enableCake {
      Bandwidth = "${cfg.cakeBandwidth}M";
      OverheadBytes = 48;
      MPUBytes = 84;
      CompensationMode = "none";
      FlowIsolationMode = "triple";
      PriorityQueueingPreset = "diffserv8";
    };

    linkConfig.RequiredForOnline = "no";
  };

  uplinkInterfaceAttrsList = lib.imap1 (
    i: v: lib.nameValuePair ("10-" + v) (generateUplinkConfiguration v (100 * (i * i)))
  ) devices.uplinks;
  uplinkInterfaceAttrs = builtins.listToAttrs uplinkInterfaceAttrsList;

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
    enableUplinkConfiguration = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      example = false;
      description = ''
        Whether to enable systemd network configuration of the uplink interface.
        Relevant if the uplink interface is being externally managed, eg, by ppp
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
    enableCake = lib.mkEnableOption "cake qdisc on the wan interface";
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
      networks = lib.mergeAttrs (if (cfg.enableUplinkConfiguration) then uplinkInterfaceAttrs else { }) {
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
            UplinkInterface = ":auto";
            DefaultLeaseTimeSec = 1800;
          };

          dhcpServerStaticLeases = [
            # {
            #   # Idac for example
            #   Address = "192.168.1.50";
            #   MACAddress = "54:9f:35:14:57:3e";
            # }
          ];

          linkConfig.RequiredForOnline = "no";

          ipv6SendRAConfig = {
            EmitDNS = "yes";
            DNS = dns6;
            EmitDomains = "no";
          };

          dhcpPrefixDelegationConfig.UplinkInterface = ":auto";
        };
      };
    };

    networking.firewall.logRefusedConnections = lib.mkForce false;

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
