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
          interface = [
            "0.0.0.0"
            "::0"
          ];
          port = 1053;
        };
        forward-zone = [
          {
            name = ".";
            forward-addr = [
              # "9.9.9.9@853#dns.quad9.net"
              # "2620:fe::fe@853#dns.quad9.net"
              # "1.1.1.1@853#cloudflare-dns.com"
              # "2606:4700:4700::1111@853#cloudflare-dns.com"
              "9.9.9.9@53"
              "1.1.1.1@53"
            ];
          }
        ];
      };
    };

    networking.firewall.interfaces.${config.homelab.router.devices.lan} = {
      allowedTCPPorts = [
        53
        1053
      ];
      allowedUDPPorts = [
        53
        1053
      ];
    };
  };
}
