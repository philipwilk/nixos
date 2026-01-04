{
  config,
  lib,
  ...
}:
let
  idmDomain = "testing-idm.fogbox.uk";
  proxyDomain = "idm-proxy.fogbox.uk";

  cfg = config.homelab.services.oauth2proxy;
in
{
  options.homelab.services.oauth2proxy.enable = lib.mkEnableOption "oauth2proxy";

  config = lib.mkIf cfg.enable {
    age.secrets.oauth2proxyClient.file = ../../secrets/oauth2proxy/client.age;
    age.secrets.oauth2proxyCookieSecret.file = ../../secrets/oauth2proxy/cookieSecret.age;
    systemd.services.oauth2-proxy = {
      serviceConfig = {
        LoadCredential = [
          "cookieFile:${config.age.secrets.oauth2proxyCookieSecret.path}"
        ];
      };
    };

    services.oauth2-proxy = {
      enable = true;
      provider = "oidc";
      scope = "openid email";
      oidcIssuerUrl = "https://${idmDomain}/oauth2/openid/oauth2proxy";
      clientID = "oauth2proxy";
      redirectURL = "https://${proxyDomain}/oauth2/callback";
      keyFile = config.age.secrets.oauth2proxyClient.path;
      reverseProxy = true;
      passAccessToken = true;
      extraConfig = {
        oidc-groups-claim = "users";
        cookie-secret-file = "/run/credentials/oauth2-proxy.service/cookieFile";
        cookie-refresh = "6h0m0s";
        code-challenge-method = "S256";
        whitelist-domain = builtins.attrNames config.services.oauth2-proxy.nginx.virtualHosts;
      };
      email.domains = [ "*" ];
      nginx.domain = proxyDomain;
    };
    networking.domains.subDomains.${proxyDomain} = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };
}
