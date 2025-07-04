{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.networking.wireguard;

  dns4 = "1.1.1.1 9.9.9.9";
  dns6 = "2606:4700:4700::1111 2620:fe::fe";

  dnsCfg = {
    DNS = "${dns6} ${dns4}";
    DNSSEC = "yes";
    DNSOverTLS = "yes";
  };
in
{
  options = {
    homelab.networking.wireguard.enable = lib.mkEnableOption "The wireguard protocol";
    homelab.networking.wireguard.isServer = lib.mkEnableOption "Act as a server";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.networking.wireguard.interfaces.wg0.privateKeyFile != null;
        message = "Wireguard private key file must be set";
      }
      {
        assertion = cfg.enable -> config.networking.wireguard.interfaces.wg0.ips != [ ];
        message = "Wireguard interface IP must be set";
      }
    ];

    networking.firewall.allowedUDPPorts = [ config.networking.wireguard.interfaces.wg0.listenPort ];
    networking.wireguard = {
      enable = true;
      useNetworkd = true;
      interfaces.wg0 = {
        listenPort = 51820;

        peers =
          if cfg.isServer then
            [
              # Laptop
              {
                publicKey = builtins.readFile ../../secrets/wireguard/probook/public;
                allowedIPs = [
                  "10.100.0.2/32"
                  "fd42:42:42::2/128"
                ];
              }
              # Pc
              {
                publicKey = builtins.readFile ../../secrets/wireguard/prime/public;
                allowedIPs = [
                  "10.100.0.3/32"
                  "fd42:42:42::3/128"
                ];
              }
            ]
          else
            [
              # Server
              {
                publicKey = builtins.readFile ../../secrets/wireguard/itxserve/public;
                allowedIPs = [
                  "0.0.0.0/0"
                  "[::]/0"
                ];
                endpoint = "sou.uk.region.fogbox.uk:${toString config.networking.wireguard.interfaces.wg0.listenPort}";
                persistentKeepalive = 25;
              }
            ];
      };
    };

    systemd.network.networks."20-wg0" =
      if cfg.isServer then
        {
          matchConfig.Name = "wg0";
          networkConfig = lib.mkMerge [
            {
              IPv4Forwarding = "yes";
              IPMasquerade = "both";
              Address = [
                "10.100.0.1/24"
                "fd42:42:42::1/64"
              ];
              LinkLocalAddressing = "ipv6";
            }
            dnsCfg
          ];
          dhcpPrefixDelegationConfig.SubnetId = "0x2";
        }
      else
        {
          networkConfig = lib.mkMerge [
            {
              Gateway = [
                "10.100.0.1"
                "fd42:42:42::1"
              ];
            }
            dnsCfg
          ];
        };
  };
}
