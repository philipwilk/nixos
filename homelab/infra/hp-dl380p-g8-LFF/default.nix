{ ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "hp-dl380p-g8-LFF";
  homelab = {
    # router.enable = true;
  };
}
