{ config, lib, ... }:
let
  r = config.homelab.router;
  routerIp = r.ip4;
  linkLocal = r.linkLocal;

  cfg = config.homelab.router.systemd;
  lan = config.homelab.router.devices.lan;
  wan = config.homelab.router.devices.wan;
  uplink = config.homelab.router.devices.uplink;
  gateway = config.homelab.router.devices.gateway;

  dns4 = routerIp;
  dns6 = linkLocal;
in
{
  options.homelab.router.systemd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.homelab.router.enable;
      example = true;
      description = ''
        Whether to enable systemd network configuration.
      '';
    };
    ipRange = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.0/16";
      example = "192.168.1.0/24";
      description = ''
        IP4 address range to use for the lan
      '';
    };
    enableCake = lib.mkEnableOption "cake qdisc on the wan interface";
    cakeBandwidth = lib.mkOption {
      type = lib.types.str;
      default = "850";
      example = "2250";
      description = ''
        Max bandwidth for CAKE qdisc, in megabits
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    systemd.network = {
      enable = true;
      config.networkConfig.IPv6Forwarding = "yes";
      networks = {
        # only configure in simple ethernet dhcp network - no custom gateway set (pppoe)
        # (uplink allows for simple ethernet dhcp with vlan)
        "10-${uplink}" = lib.mkIf (uplink == gateway) {
          matchConfig.Name = uplink;
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = "yes";
            DHCPPrefixDelegation = "yes";
            LinkLocalAddressing = "ipv6";
            IPv4Forwarding = "yes";
          };

          dhcpV4Config = {
            UseHostname = "no";
            UseDNS = "no";
            UseNTP = "no";
            UseSIP = "no";
            UseRoutes = "no";
            UseGateway = "yes";
          };

          ipv6AcceptRAConfig = {
            UseDNS = "no";
            DHCPv6Client = "yes";
          };

          dhcpPrefixDelegationConfig.UplinkInterface = ":self";

          dhcpV6Config = {
            WithoutRA = "solicit";
            UseHostname = "no";
            UseDNS = "no";
            UseNTP = "no";
          };

          cakeConfig = lib.mkIf cfg.enableCake {
            Bandwidth = "${cfg.cakeBandwidth}M";
            OverheadBytes = 48;
            MPUBytes = 84;
            CompensationMode = "none";
            FlowIsolationMode = "triple";
            PriorityQueueingPreset = "diffserv8";
          };

          linkConfig.RequiredForOnline = "no";
        };
        "15-${lan}" = {
          matchConfig.Name = lan;
          matchConfig.Type = "ether";
          networkConfig = {
            IPv6AcceptRA = "no";
            IPv6SendRA = "yes";
            LinkLocalAddressing = "ipv6";
            DHCPPrefixDelegation = "yes";
            DHCPServer = "yes";
            Address = "${routerIp}/16";
            IPv4Forwarding = "yes";
            IPMasquerade = "ipv4";
          };

          dhcpServerConfig = {
            EmitRouter = "yes";
            EmitDNS = "yes";
            DNS = dns4;
            EmitNTP = "yes";
            NTP = routerIp;
            EmitDomain = "yes";
            Domain = config.networking.fqdn;
            PoolOffset = 100;
            ServerAddress = "${routerIp}/16";
            UplinkInterface = config.homelab.router.devices.uplink;
            DefaultLeaseTimeSec = 1800;
            PersistLeases = "yes";
          };

          dhcpServerStaticLeases = [
            # {
            #   # Idac for example
            #   Address = "192.168.1.50";
            #   MACAddress = "54:9f:35:14:57:3e";
            # }
          ];

          linkConfig.RequiredForOnline = "yes";

          ipv6SendRAConfig = {
            EmitDNS = "yes";
            DNS = dns6;
            EmitDomains = "no";
          };

          dhcpPrefixDelegationConfig.UplinkInterface = uplink;
        };
      };
    };

    systemd.paths.sync-leases-with-unbound-forwards = {
      wantedBy = [ "multi-user.target" ];
      description = "create/remove forward for each lease";
      pathConfig = {
        PathChanged = /var/lib/systemd/network/dhcp-server-lease/${lan};
      };
    };
    systemd.services.sync-leases-with-unbound-forwards = {
      serviceConfig = {
        Restart = "on-failure";
      };
      script = ''
        #! /usr/bin/env nix
        #! nix shell nixpkgs#python314--command python

        import json
        import subprocess
        import os


        prev_lease_file_path = "/var/lib/systemd/networking/dhcp-server-lease/${lan}"
        unbound_control = "unbound-control"

        with open("/var/lib/systemd/network/dhcp-server-lease/lan", "r") as leases_file:
          prev_leases = {}
          if os.path.isfile(prev_lease_file_path):
            with open(prev_lease_file_path, "r+", encoding="utf-8") as prev_leases_file_r:
              if os.path.getsize(prev_lease_file_path) != 0:
                prev_leases = json.load(prev_leases_file_r)
          
          dhcp_server_info = json.load(leases_file)
          leases = dhcp_server_info["leases"]

          clients = {}
          for_removal = []
          for_addition = []
          for lease in leases:
            clientid = lease["clientid"]
            clientidhash = str(hash(tuple(clientid)))
            clients[clientidhash] = lease
            ip = lease["address"]

            if clientidhash in prev_leases:
              prev_client_lease = prev_leases[clientidhash]
              if prev_client_lease["address"] == ip:
                print(f"ip for client {clientid} is the same, {ip}")
              else:
                print(f"ip for client {clientid} is different, {ip}")
                for_removal.append(lease)
                for_addition.append(lease)
            else:
              print(f"client {clientid} is not in the previous lease file, their new ip is: {ip}")
              for_addition.append(lease)
         
          for removed_lease in for_removal:
            print(f"removing lease {removed_lease["clientid"]}")
            hostname = added_lease["hostname"] + "." + "${config.networking.fqdn}"
            result = subprocess.call(f"{unbound_control} local_data_remove {hostname}")

          for added_lease in for_addition:
            print("adding lease")
            hostname = added_lease["hostname"] + "." + "${config.networking.fqdn}"
            ip = ".".join(map(str, added_lease["address"]))  
            result = subprocess.run(f"{unbound_control} local_data {hostname} in a {ip}")

          with open(prev_lease_file_path, "w+", encoding="utf-8") as prev_leases_file_w:
            json.dump(clients, prev_leases_file_w, ensure_ascii=false, indent=4, sort_keys=true)
      '';
    };

    networking.nftables.tables = {
      firewall = {
        family = "inet";
        content = ''
          chain postrouting {
            type nat hook postrouting priority 100; policy accept

            ip saddr ${cfg.ipRange} oifname ${uplink} masquerade
            
            ip saddr ${cfg.ipRange} ip daddr ${routerIp} masquerade
          }
        '';
      };
    };
    networking.firewall.logRefusedConnections = lib.mkForce false;

    # Open ports for dhcp server on lan
    networking.firewall.interfaces.${lan}.allowedUDPPorts = [
      67
      68
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
      636
      389
      25
      465
      993
      22420
      22
      34197
    ];
  };
}
