{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.radicale;
  idmDomain = "testing-idm.fogbox.uk";
in
{
  options.homelab.services.radicale.enable = lib.mkEnableOption "radicale";
  options.homelab.services.radicale.domain = lib.mkOption {
    type = lib.types.str;
    default = "dav.${config.homelab.tld}";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.oauth2-proxy.enable;
        message = "oauth2-proxy must be enabled so radicale can be secured";
      }
    ];

    services.radicale = {
      enable = true;
      settings = {
        server.hosts = [ "0.0.0.0:5232" ];
        auth = {
          type = "http_x_remote_user";
        };
      };
    };

    services.nginx.virtualHosts = {
      ${cfg.domain} = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:5232";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Remote-User $user;
          '';
        };
      };
    };

    services.oauth2-proxy.nginx.virtualHosts.${cfg.domain} = {
      # allowed_groups = [ "users" ];
    };

    networking.domains.subDomains.${cfg.domain} = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };
}
