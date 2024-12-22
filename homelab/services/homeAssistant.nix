{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.homelab.services.homeAssistant.enable = lib.mkEnableOption "the home assistant config";

  # starting from https://wiki.nixos.org/wiki/Home_Assistant#Native_installation
  config = lib.mkIf config.homelab.services.homeAssistant.enable {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        # Components required to complete the onboarding
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"
        # Recommended for fast zlib compression
        # https://www.home-assistant.io/integrations/isal
        "isal"
        # stuff
        "nanoleaf"
        "cast"
        "denonavr"
        "androidtv_remote"
        "thread"
        "matter"
        "otbr"
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
        # for zigbee OTA
        zha.zigpy_config.ota.z2m_remote_index = "https://raw.githubusercontent.com/Koenkk/zigbee-OTA/master/index.json";
      };

      # for proxying
      config.http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };

      # For postgres use
      extraPackages = ps: with ps; [ psycopg2 ];
      config.recorder.db_url = "postgresql://@/hass";
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };

    services.nginx.virtualHosts."home.${config.homelab.tld}" = {
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.home-assistant.config.http.server_port}";
        proxyWebsockets = true;
      };
    };
  };
}
