{
  lib,
  config,
  ...
}:
let
  cfg = config.homelab.services.opencloud;
  collaboraDomain = "collabora.${config.homelab.tld}";
in
{
  options.homelab.services.opencloud = {
    enable = lib.mkEnableOption "opencloud";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "cloud.${config.homelab.tld}";
    };
    idpDomain = lib.types.str {
      type = lib.types.str;
      defaut = "testing-idm.${config.homelab.tld}";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.fileSystems."/var/lib/opencloud" == null;
        message = "The opencloud state dir must be defined (ideally as a zfs dataset)";
      }
    ];

    services.collabora-online = {
      enable = true;
      settings = {
        ssl = {
          enable = false;
          termination = true;
        };
        net = {
          listen = "loopback";
          port_allow.host = [ "127.0.0.1" ];
        };
        storage.wopi = {
          "@allow" = true;
          host = [ cfg.domain ];
        };
        server_name = collaboraDomain;
      };
    };

    services.nginx.virtualhosts.${collaboraDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.collabora-online.port}";
        proxyWebsockets = true;
      };
    };

    networking.domains.subDomains.${collaboraDomain} = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };

    services.opencloud = {
      enable = true;
      url = "https://${cfg.domain}";
      settings = {
        oc = {
          oidc_issuer = "https://${cfg.idpDomain}";
          exclude_run_services = "idp,idm";
          admin_user_id = "";
        };

        wopi = {
          wopi_server_url = "https://${collaboraDomain}";
          insecure = false;
        };

        collaboration.enable = true;

        proxy = {
          auto_provision_accounts = true;
          oidc = {
            rewrite_well_known = true;
          };
          role_assignment = {
            driver = "oidc";
            oidc_role_mapper = {
              role_claim = "opencloud_roles";
            };
          };
        };
        web = {
          web = {
            config = {
              oidc = {
                scope = "openid profile email opencloud_roles";
              };
            };
          };
        };
      };
      environment = {
        # OC_EXCLUDE_RUN_SERVICES = "idp";
        # OC_OIDC_ISSUER = "https://${cfg.idpDomain}";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.opencloud.port}";
        proxyWebsockets = true;
      };
    };

    networking.domains.subDomains.${cfg.domain} = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };
}
