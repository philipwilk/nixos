{
  pkgs,
  ...
}:
{
  services.navidrome = {
    enable = true;
    settings = {
      Address  = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/var/music";
      DataFolders = "/var/navidrome";
      CoverJpegQuality = 100;
      EnableSharing = true;
      ImageCacheSize = "250MB";
    };
  };
  networking.firewall.interfaces."eno1".allowedTCPPorts = [ 4533 ];
}
