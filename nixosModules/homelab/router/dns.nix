{
  config,
  lib,
  pkgs,
  ...
}:
let
  lan = config.homelab.router.devices.lan;
  ip4 = config.homelab.router.ip4;
in
{
  config = lib.mkIf config.homelab.router.enable {
    networking.firewall.interfaces.${lan} = {
      allowedTCPPorts = [
        53
        9153
        #config.services.adguardhome.port
      ];
      allowedUDPPorts = [
        53
      ];
    };

    # Since we manage links using networkd, need to force disable resolved so 127.0.0.53 is free
    services.resolved.enable = lib.mkForce false;

    services.redis.servers.unbound = {
      enable = true;
      port = 6399;
    };

    services.unbound = {
      enable = true;
      package = pkgs.unbound.override {
        withRedis = true;
        withSystemd = true;
      };
      settings = {
        server = {
          verbosity = 3;
          interface = [
            "0.0.0.0"
            "::0"
          ];
          port = 53;
          access-control = [
            "0.0.0.0 allow"
            "::0 allow"
          ];
          prefetch = true;
          prefetch-key = true;
          edns-buffer-size = 1232;
          module-config = "\"validator cachedb iterator\"";

          hide-identity = true;
          hide-version = true;
        };
        cachedb = {
          backend = "\"redis\"";
          redis-server-host = "127.0.0.1";
          redis-server-port = config.services.redis.servers.unbound.port;
          redis-expire-records = true;
        };
        forward-zone = [
          {
            name = ".";
            forward-addr = [
              "2620:fe::fe#dns.quad9.net"
              "9.9.9.9#dns.quad9.net"
              "2620:fe::9#dns.quad9.net"
              "149.112.112.112#dns.quad9.net"
            ];
            forward-tls-upstream = true;
          }
        ];
      };
    };
    /*
      services.adguardhome = {
        enable = true;
        port = 5353;
        host = ip4;
        mutableSettings = false;
        settings = {
          dns =
            let
              port = builtins.toString config.services.unbound.settings.server.port;
              local = [
                "[::1]:${port}"
                "127.0.0.1:${port}"
              ];

            in
            {
              bootstrap_dns = local;
              bootstrap_prefer_ipv6 = true;
              upstream_dns = local;
              upstream_mode = "parallel";
              enable_dnssec = true;
              serve_http3 = true;
              hostsfile_enabled = false;
              bind_hosts = [
                "127.0.0.1"
                "::1"
                ip4
              ];
            };

          statistics.enabled = true;

          filtering = {
            protection_enabled = true;
            filtering_enabled = true;

            safe_search = {
              enabled = false;
            };
          };

          filters = (
            map
              (url: {
                enabled = true;
                url = url;
              })
              [
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt" # Ads
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
                "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
              ]
          );
        };
      };
    */
  };
}
