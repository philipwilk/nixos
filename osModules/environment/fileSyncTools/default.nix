{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    syncthing
    nextcloud-client
  ];
}
