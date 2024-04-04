{ config, lib, ... }:
let domain = config.homelab.services.kea.hostDomain;
in {
  config = mkIf config.homelab.services.kea.enable {
    services.kea = {
      dhcpv4 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [
              # "eth0"
            ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          valid-lifetime = 4000;
          fqdn = domain;
          subnet4 = [{
            pools = [{ pool = "192.168.1.101 - 192.168.1.245"; }];
            subnet = "192.168.1.0/16";
          }];
        };
      };
      dhcpv6 = {
        enable = true;
        settings = {
          # dont have this setup on opnsense yet so idk
        };
      };
    };
  };
}
