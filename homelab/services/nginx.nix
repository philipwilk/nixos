{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.homelab.services.nginx.enable {
    networking.firewall.allowedTCPPorts = [
      443
      80
    ];
    services.nginx = {
      enable = true;
      enableQuicBPF = true;
      package = pkgs.nginxQuic;
      recommendedZstdSettings = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true;
    };
  };
}
