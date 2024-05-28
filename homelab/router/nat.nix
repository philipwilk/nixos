{
	lib,
	config,
	...
}:
{
	config = lib.mkIf config.homelab.services.router.nat.enable {
		networking.nat = {
			enable = true;
			enableIPv6 = true;
			externalInterface = config.homelab.services.router.devices.wan;
			internalInterface = [ config.homelab.services.router.devices.lan ];
			internalIps = [ config.homelab.services.router.kea.lanRange.ip4 ];
			internalIPv6s = [ config.homelab.services.router.kea.lanRange.ip6 ];
			forwardPorts = [
				{
					destination = "192.168.1.10:443";
					proto = "tcp";
					sourcePort = 443;
				}
				{
					destination = "192.168.1.10:80";
					proto = "tcp";
					sourcePort = 80;
				}
			];
		};
	};
}
