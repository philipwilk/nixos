{ config, lib, ... }:
let
  routerIp = "192.168.1.1";

  cfg = config.homelab.router.systemd;
  lan = config.homelab.router.devices.lan;
  wan = config.homelab.router.devices.wan;

  dns4 = "9.9.9.9 1.1.1.1";
  dns6 = "2620:fe::fe 2606:4700:4700::1111";

  dnsCfg = {
    DNS = "${dns6} ${dns4}";
    DNSSEC = "yes";
    DNSOverTLS = "yes";
  };
in
{
  options.homelab.router.systemd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.homelab.router.enable;
      example = true;
      description = ''
        Whether to enable the systemd networkd config.
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
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    systemd.network = {
      enable = true;
      networks = {
        "10-${wan}" = {
          matchConfig.Name = wan;
          networkConfig = lib.mkMerge [
            {
              DHCP = "yes";
              IPv6AcceptRA = "yes";
              LinkLocalAddressing = "ipv6";
            }
            dnsCfg
          ];

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

          dhcpV6Config = {
            WithoutRA = "solicit";
            UseDelegatedPrefix = true;
            UseHostname = "no";
            UseDNS = "no";
            UseNTP = "no";
          };
          linkConfig.RequiredForOnline = "routable";
        };
        "15-${lan}" = {
          matchConfig.Name = lan;
          networkConfig = lib.mkMerge [
            {
              IPv6AcceptRA = "no";
              IPv6SendRA = "yes";
              LinkLocalAddressing = "ipv6";
              DHCPPrefixDelegation = "yes";
              # DHCPServer = "yes";
              Address = "${routerIp}/16";
            }
            dnsCfg
          ];
          # dhcpServerConfig = {
          #   EmitDNS = "yes";
          #   DNS = dns4;
          #   EmitNTP = "yes";
          #   NTP = routerIp;
          #   PoolOffset = 100;
          #   ServerAddress = "${routerIp}/16";
          # };
          linkConfig.RequiredForOnline = "no";
          ipv6SendRAConfig = {
            EmitDNS = "yes";
            DNS = dns6;
            EmitDomains = "no";
          };
          dhcpPrefixDelegationConfig.SubnetId = "0x1";
        };
      };
    };
  };
}
