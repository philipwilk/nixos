{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ]
  ++ [
    ../../osModules/classes/personalDevice
  ];

  users.users.philip.packages = with pkgs; [ xivlauncher ];

  flakeConfig.environment.declarativeHome.enable = true;

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  system.stateVersion = "23.05";
}
