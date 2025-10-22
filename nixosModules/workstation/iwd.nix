{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.workstation.iwd.enabled = lib.mkEnableOption "the iwd wifi backend";

  config = lib.mkIf config.workstation.iwd.enabled {
    environment.systemPackages = with pkgs; [
      impala
    ];
    networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd = {
      enable = true;
      settings = {
        General = {
          UseDefaultNetwork = true;
        };
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
          NameResolvingService = "systemd";
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };
  };
}
