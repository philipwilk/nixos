{ config, lib, ... }:
let
  domain = config.homelab.router.kea.hostDomain;
  router.ip4 = "192.168.1.0";

  cfg = config.homelab.router.kea;
  lan = config.homelab.router.devices.lan;
  wan = config.homelab.router.devices.wan;
in
{
  options.homelab.router.kea = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.homelab.router.enable;
      example = true;
      description = ''
        Whether to enable the Kea dhcp server.
      '';
    };
    hostDomain = lib.mkOption {
      type = lib.types.str;
      default = "fog.${config.homelab.tld}";
      example = "lan.example.com";
      description = ''
        Domain for hosts on the local net.
      '';
    };
    lanRange = {
      ip4 = lib.mkOption {
        type = lib.types.str;
        default = "192.168.1.0/16";
        example = "192.168.1.0/24";
        description = ''
          IP4 address range to use for the lan
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    systemd.network = {
        enable = true;
        networks = {
            "10-${wan}" = {
                matchConfig.Name = wan;
                networkConfig = {
                    DHCP = "yes";
                    IPv6AcceptRA = "yes";
                    LinkLocalAddressing="ipv6";
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
                networkConfig = {
                    IPv6AcceptRA = "no";
                    IPv6SendRA = "yes";
                    LinkLocalAddressing = "ipv6";
                    DHCPPrefixDelegation = "yes";
                };
                linkConfig.RequiredForOnline = "no";
                address = [
                  cfg.lanRange.ip4
                ];
                ipv6SendRAConfig = {
                  EmitDNS = "no";
                  EmitDomains = "no";
                };
                dhcpPrefixDelegationConfig.SubnetId = "0x1";
            };
        };
    };
    services.resolved.enable = false;

    services.kea = {
      dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [ config.homelab.router.devices.lan ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          valid-lifetime = 4000;

          subnet4 = [
            {
              id = 1;
              pools = [ { pool = "192.168.1.101 - 192.168.1.245"; } ];
              subnet = config.homelab.router.kea.lanRange.ip4;
              option-data = [
                {
                  name = "domain-name-servers";
                  data = router.ip4;
                }
                {
                  name = "routers";
                  data = router.ip4;
                }
                {
                  name = "domain-name";
                  data = domain;
                }
                {
                  name = "ntp-servers";
                  data = router.ip4;
                }
              ];
              # ip and hostname reservations
              reservations = [
                # Tinyminimicro node
                {
                  hw-address = "44:8a:5b:de:13:28";
                  ip-address = "192.168.1.10";
                  hostname = "thinkcentre";
                }
                # Lights out management
                {
                  hw-address = "54:9f:35:14:57:3e";
                  ip-address = "192.168.1.50";
                  hostname = "idrac-poweredge";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
