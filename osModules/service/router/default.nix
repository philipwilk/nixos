{ lib, config, ... }:
let
  join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);
  cfg = config.homelab.router;
in
{
  imports = join-dirfile "./" [
    "systemd"
    "ntpd-rs"
    "dns"
  ];

  options.homelab.router = {
    enable = lib.mkEnableOption "Router components";
    linkLocal = lib.mkOption {
      type = lib.types.str;
      example = "fe80::...";
      description = ''
        Link local ip address of the router's lan port.
      '';
    };
    ip4 = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.1";
      example = "192.168.0.1";
      description = ''
        The router's ip4 LAN address
      '';
    };
    devices = {
      wan = lib.mkOption {
        type = lib.types.str;
        default = config.homelab.net.wan;
        example = "eth1";
        description = ''
          Network to use as the "wan" interface.
        '';
      };
      lan = lib.mkOption {
        type = lib.types.str;
        default = config.homelab.net.lan;
        example = "eth0";
        description = ''
          Network to use as the "lan" interface.
        '';
      };
      wanMac = lib.mkOption {
        type = lib.types.str;
        description = ''
          Mac address of the "wan" interface.
        '';
      };
      lanMac = lib.mkOption {
        type = lib.types.str;
        description = ''
          Mac address of the "lan" interface.
        '';
      };
      uplinks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ cfg.devices.wan ];
        description = ''
          Devices that will be used as upstreams for the lan.
          The route metric will be automatically configured in the same order that devices have been passed
        '';
      };
    };
  };
}
