{
	lib,
	config,
	...
}:
let
	domain = "dns.${config.homelab.tld}";
in
{
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
							"9.9.9.11@853#dns11.quad9.net"
							"2620:fe::11@853#dns11.quad9.net"
							"1.1.1.1@853#cloudflare-dns.com"
							"2606:4700:4700::1111@853#cloudflare-dns.com"
						];
					}
				];
			};
		};

    networking.firewall.interfaces.${config.homelab.router.devices.lan} = {
			allowedTCPPorts = [
				53
			];
    	allowedUDPPorts = [
				53
    	];
		};	
	};
}
