{ config, lib, ... }:
let
  router.ip4 = "192.168.1.1";

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
  };

  config = lib.mkIf cfg.enable {
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
              subnet = config.homelab.router.systemd.ipRange;
              option-data = [
                {
                  name = "domain-name-servers";
                  data = "9.9.9.9, 1.1.1.1";
                }
                {
                  name = "routers";
                  data = router.ip4;
                }
                {
                  name = "ntp-servers";
                  data = router.ip4;
                }
              ];
              # ip and hostname reservations
              reservations = [
                # Lights out management
                # {
                #   hw-address = "54:9f:35:14:57:3e";
                #   ip-address = "192.168.1.50";
                #   hostname = "idrac-poweredge";
                # }
              ];
            }
          ];
        };
      };
    };
  };
}
