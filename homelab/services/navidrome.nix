{
  config,
  pkgs,
  lib,
  ...
}:
let
  musicFolder = "/mnt/zfs/colossus/media/music";
in
{
  options.homelab.services.navidrome.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable the navidrome service.
    '';
  };
  config = lib.mkIf config.homelab.services.navidrome.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        Port = 4533;
        MusicFolder = musicFolder;
        DataFolders = "${config.homelab.stateDir}/navidrome";
        CoverJpegQuality = 100;
        EnableSharing = true;
        ImageCacheSize = "250MB";
      };
    };

    systemd.services.navidrome.serviceConfig.ReadOnlyPaths = [
      musicFolder
    ];

    services.nginx.virtualHosts."navi.${config.homelab.tld}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}";
        proxyWebsockets = true;
      };
    };
  };
}
