{ lib
, pkgs
, config
, ...
}:
{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    enableNvidia = true;
  };
}
