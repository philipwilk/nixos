{
  pkgs,
  lib,
  config,
  ...
}:
let
  otbrApiPort = 8081;
  otbrPort = 8086;
  ezspRadio = "/dev/ttyUSB0";
  threadRadio = "/dev/ttyUSB1";
  dongleDevice = threadRadio;
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
        "mqtt"
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };

        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";

        # to use postgres
        recorder.db_url = "postgresql://@/hass";
      };
      extraPackages = ps: with ps; [ psycopg2 ];
    };

    # mosquitto is the mqtt server, zigbee2mqtt deals with the dongle
    age.secrets.zigbeeMqttPwd = {
      file = ../../secrets/mosquitto/zigbeeMqttPwd.age;
    };
    age.secrets.homeassistantMqttPwd = {
      file = ../../secrets/mosquitto/homeassistantMqttPwd.age;
    };
    age.secrets.zigbeeMqttPwdYml = {
      file = ../../secrets/mosquitto/zigbeeMqttPwdYml.age;
    };
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users = {
            zigbee2mqtt = {
              passwordFile = config.age.secrets.zigbeeMqttPwd.path;
              acl = [
                "read zigbee2mqtt/#"
                "write zigbee2mqtt/#"
                "read homeassistant/#"
                "write homeassistant/#"
              ];
            };
            hazigbee = {
              passwordFile = config.age.secrets.homeassistantMqttPwd.path;
              acl = [
                "read zigbee2mqtt/#"
                "write zigbee2mqtt/#"
                "read homeassistant/#"
                "write homeassistant/#"
              ];
            };
          };
        }
      ];
    };
    systemd.services.zigbee2mqtt.serviceConfig = {
      LoadCredential = [
        "mqttPwd.yaml:${config.age.secrets.zigbeeMqttPwdYml.path}"
      ];
      Restart = lib.mkForce "always";
      RestartSec = "10s";
      StandardError = "inherit";
      StandardOutput = "inherit";
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        homeassistant = {
          enabled = config.services.home-assistant.enable;
          discover_topic = "homeassistant";
          status_topic = "homeassistant/status";
        };
        serial = {
          port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_2086ce948b38ef11b625317af3d9b1e5-if00-port0";
          adapter = "ember";
        };
        frontend = {
          enable = true;
          port = 8888;
        };
        mqtt = {
          server = "mqtt://localhost:1883";
          version = 5;
          user = "zigbee2mqtt";
          password = "!/run/credentials/zigbee2mqtt.service/mqttPwd.yaml password";
        };
      };
    };

    # for silabs multiprotocol
    # https://hub.docker.com/r/b2un0/silabs-multipan-docker
    networking.firewall.interfaces.${config.homelab.net.lan}.allowedTCPPorts = [
      otbrPort
      config.services.zigbee2mqtt.settings.frontend.port
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
    /*
      boot.kernelModules = [ "ip6table_filter" ];
      virtualisation.oci-containers.containers."otbr" = {
        image = "docker.io/openthread/otbr:latest";
        devices = [
          dongleDevice
          "/dev/net/tun"
        ];
        capabilities = {
          CAP_NET_ADMIN = true;
          CAP_NET_RAW = true;
          CAP_SYSLOG = true;
        };
        cmd = [
          "--radio-url \"spinel+hdlc+uart://${dongleDevice}?uart-baudrate=460800\""
        ];
        extraOptions = [
          "--sysctl net.ipv6.conf.all.disable_ipv6=0"
          "--sysctl net.ipv4.conf.all.forwarding=1"
          "--sysctl net.ipv6.conf.all.forwarding=1"
        ];
        ports = [
          "8081:8081"
          "8086:80"
        ];
        volumes = [ "${config.homelab.stateDir}/multipan:/data:Z" ];
      };
    */

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

    networking.domains.subDomains."home.${config.homelab.tld}" = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };
}
