{
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "itxserve"; # Define your hostname.
  networking.hostId = "9e09d7d7"; # needed for zfs
  
  system.stateVersion = "24.11"; # Did you read the comment?
}
