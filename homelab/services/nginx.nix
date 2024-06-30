{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homelab.services.nginx.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable nginx for proxying/load balancing.
    '';
  };
  
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

      virtualHosts.default = {
        default = true;
        locations."/".return = "404";
      };
    };
  };
}
