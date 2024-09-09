{ config, lib, ... }:
let
  domain = config.homelab.router.kea.hostDomain;
  router.ip4 = "192.168.1.0";
  router.ip6 = "2001:db8:1::1";

  cfg = config.homelab.router.kea;
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
      ip6 = lib.mkOption {
        type = lib.types.str;
        default = "2001:db8:1::/64";
        description = ''
          IP6 address range to use for the lan
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.interfaces.${config.homelab.router.devices.lan} = {
      ipv4.addresses = [
        {
          address = router.ip4;
          prefixLength = 16;
        }
      ];
      ipv6.addresses = [
        {
          address = router.ip6;
          prefixLength = 64;
        }
      ];
    };
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
      dhcp6 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [ config.homelab.router.devices.lan ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp6.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          valid-lifetime = 4000;

          subnet6 = [
            {
              id = 1;
              pools = [ { pool = "2001:db8:1::1-2001:db8:1::ffff"; } ];
              subnet = config.homelab.router.kea.lanRange.ip6;
              interface = config.homelab.router.devices.lan;
              option-data = [
                {
                  name = "domain-name-servers";
                  data = router.ip6;
                }
                {
                  name = "routers";
                  data = router.ip6;
                }
                {
                  name = "domain-name";
                  data = domain;
                }
                {
                  name = "ntp-servers";
                  data = router.ip6;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
