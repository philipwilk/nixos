{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    impala
    iwgtk
    iwmenu
  ];
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd = {
    enable = lib.mkDefault true;
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

  systemd.services.iwd.serviceConfig.ExecStartPre =
    let
      sleep = lib.getExe' pkgs.uutils-coreutils "uutils-sleep";
    in
    [
      "${sleep} 2s"
    ];
}
