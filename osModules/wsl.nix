{
  config,
  ...
}:
let
  user = config.wsl.defaultUser;
in
{
  imports = [
    ./system/security

    ./environment/containers
    ./environment/nixTools
    ./environment/fonts

    ./environment/programs/openssh
    ./environment/programs/homeManager
  ];

  flakeConfig.system.bootable.enable = false;

  networking.nftables.enable = false;
  environment.sessionVariables.NH_FLAKE = "/home/${user}/repos/nixos";

  wsl.enable = true;
  wsl.docker-desktop.enable = true;
  age.identityPaths = [ "/home/${user}/.ssh/id_ed25519" ];

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "adbusers"
      "video"
      "input"
      "plugdev"
      "podman"
    ];
  };
}
