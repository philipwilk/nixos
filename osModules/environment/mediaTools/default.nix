{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    vlc
    #jellyfin-media-player
    spotify
  ];
}
