{ lib, config, ... }:
let
  # ip4:port, ip6:port, proto, sourcePort
  createRule = dst: protocol: source: [
    {
      destination = dst;
      proto = protocol;
      sourcePort = source;
    }
  ];
  # Uses same port for source and destination for ip4 and ip6
  # ip4, ip6, proto, sourcePort
  quickRule = dst: protocol: source:
    createRule "${dst}:${toString source}" protocol source;
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

    networking.firewall.allowedTCPPorts = [ 80 443 636 389 25 465 993 22420 22 34197 ];
    
    networking.nat = {
      enable = true;
      externalInterface = wan;
      internalInterfaces = [ lan ];
      internalIPs = [ config.homelab.router.systemd.ipRange ];
    };
  };
}
