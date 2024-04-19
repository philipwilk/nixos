{ config, lib, ... }: {
  config = lib.mkIf config.homelab.services.vaultwarden.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vault.fogbox.uk";
        SIGNUPS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
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
