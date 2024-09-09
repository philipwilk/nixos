{ lib, config, ... }:
let
  # ip4:port, ip6:port, proto, sourcePort
  createRule = dst4: dst6: protocol: source: [
    {
      destination = dst4;
      proto = protocol;
      sourcePort = source;
    }
    {
      destination = dst6;
      proto = protocol;
      sourcePort = source;
    }
  ];
  # Uses same port for source and destination for ip4 and ip6
  # ip4, ip6, proto, sourcePort
  quickRule =
    dst4: dst6: protocol: source:
    createRule "${dst4}:${toString source}" "${dst6}:${toString source}" protocol source;
  lan = config.homelab.router.devices.lan;
  wan = config.homelab.router.devices.wan;
in
{
  options.homelab.router.nat.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.homelab.router.enable;
    example = true;
    description = ''
      Whether to enable network address translation.
    '';
  };

  config = lib.mkIf config.homelab.router.nat.enable {
    networking.nftables = {
      enable = true;
      flushRuleset = true;
    };
    networking.nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = wan;
      internalInterfaces = [ lan ];
      internalIPs = [ config.homelab.router.kea.lanRange.ip4 ];
      internalIPv6s = [ config.homelab.router.kea.lanRange.ip6 ];
      forwardPorts = lib.flatten [
        # Http
        (quickRule "127.0.0.1" "[::1]" "tcp" 80)
        # Https
        (quickRule "127.0.0.1" "[::1]" "tcp" 443)
        # Factorio
        (quickRule "127.0.0.1" "[::1]" "udp" 34197)
        # Ldap
        (quickRule "127.0.0.1" "[::1]" "tcp" 389)
        # Ldaps
        (quickRule "127.0.0.1" "[::1]" "tcp" 636)
        # Ssh
        (quickRule "127.0.0.1" "[::1]" "tcp" 22)
        (quickRule "127.0.0.1" "[::1]" "tcp" 22420)
        # SMTP
        (quickRule "127.0.0.1" "[::1]" "tcp" 25)
        # SMTP/S submissions
        (quickRule "127.0.0.1" "[::1]" "tcp" 465)
        # IMAP/S
        (quickRule "127.0.0.1" "[::1]" "tcp" 993)
      ];
    };
  };
}
