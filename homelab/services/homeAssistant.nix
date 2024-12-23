{
  pkgs,
  lib,
  config,
  ...
}:
let
  otbrApiPort = 8081;
  otbrPort = 8086;
  dongleDevice = "/dev/ttyUSB0";
in
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

        # to use postgres
        recorder.db_url = "postgresql://@/hass";
      };
      extraPackages = ps: with ps; [ psycopg2 ];
    };

    # for silabs multiprotocol
    # https://hub.docker.com/r/b2un0/silabs-multipan-docker
    networking.firewall.allowedTCPPorts = [
      otbrPort
    ];
    #virtualisation.oci-containers.containers."silabs-multipan" = {
    #  image = "docker.io/b2un0/silabs-multipan-docker:2.4.5";
    #  environment = {
    #    BACKBONE_IF = config.homelab.net.lan;
    #    DEVICE = dongleDevice;
    #    FLOW_CONTROL = "false";
    #  };
    #  devices = [
    #    "${dongleDevice}:${dongleDevice}"
    #    "/dev/net/tun"
    #  ];
    #  capabilities = {
    #    CAP_NET_ADMIN = true;
    #    CAP_NET_RAW = true;
    #  };
    #  extraOptions = [
    #    "--network=host"
    #  ];
    #  ports = [
    #    "${toString otbrPort}:${toString otbrPort}"
    #    "${toString otbrApiPort}:${toString otbrApiPort}"
    #  ];
    #  volumes = [ "${config.homelab.stateDir}/multipan:/data:Z" ];
    #};
    #
    virtualisation.oci-containers.containers."otbr" = {
      image = "docker.io/openthread/otbr:latest";
      environment = {
        INFRA_IF_NAME = config.homelab.net.lan;
      };
      devices = [
        dongleDevice
      ];
      capabilities = {
        CAP_NET_ADMIN = true;
        CAP_NET_RAW = true;
      };
      privileged = true;
      cmd = [
        "--radio-url=spinel+hdlc+uart://${dongleDevice}"
      ];
      ports = [
        "8081:8081"
        "8086:80"
      ];
    };

    services.matter-server.enable = true; # needs stateDir patch
    hardware.bluetooth.enable = true;

    # for proxying
    services.home-assistant.config.http = {
      server_host = "::1";
      trusted_proxies = [ "::1" ];
      use_x_forwarded_for = true;
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
