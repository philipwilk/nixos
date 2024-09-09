{ lib, config, ... }:
let
  domain = "dns.${config.homelab.tld}";
in
{
  options.homelab.router.unbound.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.homelab.router.enable;
    example = true;
    description = ''
      Whether to enable the unbound domain name server.
    '';
  };

  config = lib.mkIf config.homelab.router.unbound.enable {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          prefer-ip6 = "yes";
          prefetch = "yes";
          prefetch-key = "yes";
          interface = [
            "0.0.0.0"
            "::0"
          ];
          access-control = [
            "${config.homelab.router.kea.lanRange.ip4} allow"
            "${config.homelab.router.kea.lanRange.ip6} allow"
          ];
        };
        forward-zone = [
          {
            name = ".";
            forward-tls-upstream = "yes";
            forward-no-cache = "no";
            forward-addr = [
              "9.9.9.9@853#dns.quad9.net"
              "2620:fe::fe@853#dns.quad9.net"
              "1.1.1.1@853#cloudflare-dns.com"
              "2606:4700:4700::1111@853#cloudflare-dns.com"
            ];
          }
        ];
      };
    };

    networking.firewall.interfaces.${config.homelab.router.devices.lan} = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
