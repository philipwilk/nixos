{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../osModules/classes/personalDevice
  ];

  users.users.philip.packages = with pkgs; [ xivlauncher ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  flakeConfig.environment.primaryHomeManagedUser = "philip";
  home-manager.users."philip".imports = [
    ../../hmModules/programs/sway
    ../../hmModules/guiConfig
    (
      {
        ...
      }:
      {
        home.stateVersion = "24.05";
      }
    )
  ];

  system.stateVersion = "23.05";
}
