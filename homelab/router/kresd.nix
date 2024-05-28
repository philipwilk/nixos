{
	lib,
	config,
	...
}:
let
	domain = "dns.${config.homelab.tld}";
in
{
	config = lib.mkIf config.homelab.services.router.kresd.enable {
		services.kresd = {
			enable = true;
			listenTLS = [
			  "[::1]:853"
			  "127.0.0.1:853"
			];
			listenPlain = [
			  "[::1]:53"
			  "127.0.0.1:53"
			];
			extraConfig = ''
				net.tls("cert.pem", "key.pem")
			'';
		};
		systemd.services."kresd@".serviceConfig = {
      wants = [ "acme-${domain}.service" ];
      after = [ "acme-${domain}.service" ];
      serviceConfig = {
        LoadCredential = [
          "cert.pem:/var/lib/acme/${domain}/cert.pem"
          "key.pem:/var/lib/acme/${domain}/key.pem"
        ];
			};
		};
		security.acme.certs."${domain}" = {};

    networking.firewall.interfaces.${config.homelab.services.router.devices.lan}.allowedTCPPorts = [
			53
			853
    ];
	};
}
