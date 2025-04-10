{ config, lib, ... }:
{
  options.workstation.iwd.enabled = lib.mkEnableOption "the iwd wifi backend";

  config = lib.mkIf config.workstation.iwd.enabled {
    networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd = {
      enable = true;
      settings = {
        General = {
          ControlPortOverNL80211 = false;
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
    systemd.network =
      let
        net = "wlan0";
      in
      {
        enable = true;
        networks.${net} = {
          matchConfig.Name = net;
          networkConfig = {
            DHCP = "yes";
            IgnoreCarrierLoss = 3;
            IPv6PrivacyExtensions = "kernel";
          };
        };
      };
  };
}
