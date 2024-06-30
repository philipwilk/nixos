{ config, lib, ... }:
{
  config = lib.mkIf config.homelab.services.vaultwarden.enable {
    age.secrets.vaultwarden_smtp.file = ../../secrets/vaultwarden_smtp.age;
    services.vaultwarden = {
      enable = true;
      environmentFile = config.age.secrets.vaultwarden_smtp.path;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vault.fogbox.uk";
        SIGNUPS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
        SMTP_HOST = "fogbox.uk";
        SMTP_FROM = "vaultwarden@services.fogbox.uk";
        SMTP_PORT = 465;
        SMTP_SECURITY = "force_tls";
        SMTP_USERNAME = "vaultwarden";
        # SMTP_PASSWORD = ... This is defined in vaultwarden_smtp env file
      };
    };

    services.nginx.virtualHosts."vault.${config.homelab.tld}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        proxyWebsockets = true;
      };
    };
  };
}
