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

  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config.acmeRoot = lib.mkDefault null;
      config.forceSSL = lib.mkDefault true;
      config.enableACME = lib.mkDefault true;
    });
  };

  config = lib.mkIf config.homelab.services.nginx.enable {
    networking.firewall.interfaces.${config.homelab.net.lan}.allowedTCPPorts = [
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
        forceSSL = false;
        enableACME = false;
        locations."/".return = "404";
      };
    };
  };
}
