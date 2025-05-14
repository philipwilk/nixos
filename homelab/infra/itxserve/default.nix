{
  config,
  pkgs,
  ...
}:
let
  platformControllerId = "/sys/devices/platform/nct6775.656/hwmon/hwmon0";
in
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "itxserve"; # Define your hostname.
  networking.hostId = "9e09d7d7"; # needed for zfs

  system.stateVersion = "24.11"; # Did you read the comment?

  homelab = {
    hostname = "sou.uk.region.fogbox.uk";
    isLeader = true;
    stateDir = "/pool";
    router = {
      enable = true;
      devices.wan = "enp4s0";
      devices.lan = "enp5s0";
    };
    services = {
      nginx.enable = true;
      jupyterhub.enable = true;
      nextcloud = {
        enable = true;
        domain = "cloud.${config.homelab.tld}";
      };
      navidrome.enable = true;
      openldap.enable = true; # needs stateDir fix
      vaultwarden.enable = true; # needs stateDir fix, /var/lib/vaultwarden
      mediawiki = {
        # needs statedir fix
        enable = true;
        name = "CS lore";
      };
      email.enable = true;
      mastodon.enable = true; # needs stateDir fix
      soft-serve.enable = true; # needs stateDir fix
      searxng.enable = true;
      jellyfin.enable = true;
    };
  };
  homelab.buildbot = {
    enableWorker = true;
    enableMaster = true;
  };
  homelab.nix = {
    #hercules-ci.enable = true;
    harmonia.enable = true;
  };

  age.secrets.itxservePriv.file = ../../../secrets/wireguard/itxserve/private.age;
  homelab.networking.wireguard = {
    enable = true;
    isServer = true;
  };
  networking.wireguard.interfaces.wg0 = {
    privateKeyFile = config.age.secrets.itxservePriv.path;
    ips = [ "10.100.0.1/24" ];
  };

  homelab.games = {
    # Needs statedir option fix /var/lib/factorio
    factorio = {
      enable = true;
      admins = [ "wiryfuture" ];
    };
  };

  services.factorio.saveName = "space";

  homelab.ci.runners.gitlab.csgitlab.enabled = true;

  boot.kernelModules = [ "nct6775" ];
  environment.etc."fancontrol".text = ''
    INTERVAL=10
    DEVPATH=hwmon0=${platformControllerId}
    DEVNAME=hwmon0=nct6798
    FCTEMPS=
    FCFANS= hwmon0/pwm1=hwmon0/fan1_input hwmon0/pwm4=hwmon0/fan4_input
    MINTEMP=
    MAXTEMP=
    MINSTART=
    MINSTOP=
  '';
  environment.systemPackages = with pkgs; [ hddfancontrol ];
  services.hddfancontrol = {
    enable = true;
    settings =
      let
        byId = builtins.map (disk: "/dev/disk/by-id/${disk}");
      in
      {
        lffBay = {
          pwmPaths = [ "${platformControllerId}/pwm4:25:10" ];
          disks = byId [
            "scsi-35000cca2530a67ec"
            "scsi-35000cca2530c4cbc"
            "scsi-35000cca2530cd21c"
            "scsi-35000cca2530cf7b8"
            "scsi-35000cca2530d3dd4"
            "scsi-35000cca2530d5a24"
            "scsi-35000cca2530a7f1c"
            "scsi-35000cca2530cf2a4"
          ];
          extraArgs = [
            "--interval=30s"
          ];
        };
        sffBay = {
          pwmPaths = [ "${platformControllerId}/pwm1:80:55" ];
          disks = byId [
            "ata-KIOXIA-EXCERIA_SATA_SSD_62RB71ENKFV4"
            "ata-KIOXIA-EXCERIA_SATA_SSD_72GB81JJKLQ4"
            "ata-KIOXIA-EXCERIA_SATA_SSD_72JB81UEKFV4"
            "ata-KIOXIA-EXCERIA_SATA_SSD_72JB81UIKFV4"
          ];
          extraArgs = [
            "--interval=30s"
          ];
        };
      };
  };
  age.secrets.nutHtpasswd = {
    file = ../../../secrets/prometheus/exporters/nut/htpasswd.age;
    owner = "nginx";
  };
  services.prometheus.exporters.nut.enable = true;
  services.nginx.virtualHosts."nut.stats.${config.homelab.hostname}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.exporters.nut.port}";
      proxyWebsockets = true;
      basicAuthFile = config.age.secrets.nutHtpasswd.path;
    };
  };

  age.secrets.upsmonSou.file = ../../../secrets/upsmon/sou.age;
  power.ups = {
    enable = true;

    ups."SMT1500I" = {
      driver = "usbhid-ups";
      port = "auto";
    };

    users.upsmon = {
      passwordFile = config.age.secrets.upsmonSou.path;
      upsmon = "primary";
    };

    upsmon.monitor."SMT1500I".user = "upsmon";
  };
}
