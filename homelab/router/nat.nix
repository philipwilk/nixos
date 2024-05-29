{
	lib,
	config,
	...
}:
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
	quickRule = dst4: dst6: protocol: source:
		createRule "${dst4}:${toString source}" "[${dst6}]:${toString source}" protocol source;
in
{
	config = lib.mkIf config.homelab.router.nat.enable {
		networking.nat = {
			enable = true;
			enableIPv6 = true;
			externalInterface = config.homelab.router.devices.wan;
			internalInterface = [ config.homelab.router.devices.lan ];
			internalIps = [ config.homelab.router.kea.lanRange.ip4 ];
			internalIPv6s = [ config.homelab.router.kea.lanRange.ip6 ];
			forwardPorts = lib.flatten [
				# Http
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 80)
				# Https
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 443)
				# Factorio
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "udp" 34197)
				# Ldap
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 389)
				# Ldaps
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 636)
				# Ssh
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 22)
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 22420)
				# SMTP
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 25)
				# SMTP/S submissions
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 465)
				# IMAP/S
				(quickRule "192.168.1.10" "[2a0e:cb01:1d:1200::16a1]" "tcp" 993)
			];
		};
	};
}
