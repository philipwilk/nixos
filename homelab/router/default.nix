{ lib, config, ... }:
let
  join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);
  mkOpt = lib.mkOption;
  t = lib.types;
in
{
  imports = join-dirfile "./" [
    "kea"
    "ntpd-rs"
    "unbound"
    "nat"
  ];

  options.homelab.router = {
    enable = lib.mkEnableOption "Router components";
    devices = {
      wan = mkOpt {
        type = t.str;
        default = "eno1";
        example = "eth1";
        description = ''
          Network to use as the "wan" interface.
        '';
      };
      lan = mkOpt {
        type = t.str;
        default = "eno2";
        example = "eth0";
        description = ''
          Network to use as the "lan" interface.
        '';
      };
    };
    kea = {
      enable = mkOpt {
        type = t.bool;
        default = config.homelab.router.enable;
        example = true;
        description = ''
          Whether to enable the Kea dhcp server.
        '';
      };
      hostDomain = mkOpt {
        type = t.str;
        default = "fog.${config.homelab.tld}";
        example = "lan.example.com";
        description = ''
          Domain for hosts on the local net.
        '';
      };
      lanRange = {
        ip4 = mkOpt {
          type = t.str;
          default = "192.168.1.0/16";
          example = "192.168.1.0/24";
          description = ''
            IP4 address range to use for the lan
          '';
        };
        ip6 = mkOpt {
          type = t.str;
          default = "2001:db8:1::/64";
          description = ''
            IP6 address range to use for the lan
          '';
        };
      };
    };
    ntpd-rs.enable = mkOpt {
      type = t.bool;
      default = config.homelab.router.enable;
      example = true;
      description = ''
        Whether to enable the ntpd-rs NTP server.
      '';
    };
    unbound.enable = mkOpt {
      type = t.bool;
      default = config.homelab.router.enable;
      example = true;
      description = ''
        Whether to enable the unbound domain name server.
      '';
    };
    nat.enable = mkOpt {
      type = t.bool;
      default = config.homelab.router.enable;
      example = true;
      description = ''
        Whether to enable network address translation.
      '';
    };
  };
}
