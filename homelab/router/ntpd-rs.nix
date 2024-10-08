{ lib, config, ... }:
{
  options.homelab.router.ntpd-rs.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.homelab.router.enable;
    example = true;
    description = ''
      Whether to enable the ntpd-rs NTP server.
    '';
  };

  config = lib.mkIf config.homelab.router.ntpd-rs.enable {
    services.ntpd-rs = {
      enable = true;
      useNetworkingTimeServers = false;
      metrics.enable = true;
      settings = {
        source = [
          {
            mode = "pool";
            address = "uk.pool.ntp.org";
            count = 4;
          }
        ];
        server = [
          { listen = "127.0.0.1:123"; }
          { listen = "[::1]:123"; }
        ];
      };
    };
    networking.firewall.interfaces.${config.homelab.router.devices.lan}.allowedUDPPorts = [ 123 ];
  };
}
