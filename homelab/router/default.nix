{ lib, config, ... }:
let
  join-dirfile = dir: files: (map (file: ./${dir}/${file}.nix) files);
in
{
  imports = join-dirfile "./" [
    "systemd"
    "ntpd-rs"
    "nat"
    "kea"
  ];

  options.homelab.router = {
    enable = lib.mkEnableOption "Router components";
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
    };
  };
}
