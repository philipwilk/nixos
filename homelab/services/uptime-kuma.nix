{ config, lib, ... }:
{
  options.homelab.services.uptime-kuma.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to eanble the uptime kuma monitor.
    '';
  };

  config = lib.mkIf config.homelab.services.uptime-kuma.enable {
    services.uptime-kuma = {
      enable = true;
      appriseSupport = true;
      settings = {
        HOST = "127.0.0.1";
      };
    };

    # The default port is 3001 (there is no option for it)
    services.nginx.virtualHosts."status.${config.homelab.tld}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
      };
    };
  };
}
