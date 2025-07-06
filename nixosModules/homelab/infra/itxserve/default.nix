{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostId = "9e09d7d7"; # needed for zfs

  system.stateVersion = "24.11"; # Did you read the comment?

  systemd.network.links =
    let
      lan = config.homelab.router.devices.lan;
      wan = config.homelab.router.devices.wan;
    in
    {
      "link-${wan}" = {
        matchConfig.Name = wan;
        linkConfig = {
          # WAN link is defaulting to 100mbps
          # Think it is due to spurious rx errors
          # Need to replace the link cable so it doesn't happen in the first place
          # but i cba atm
          BitsPerSecond = "1G";
          Duplex = "full";
        };
      };
      "link-${lan}" = {
        matchConfig.Name = lan;
        linkConfig = {
          # LAN link is defaulting to 100mbps
          # ethtool claims link partner only advertises up to 100baseT/Full...
          # xiaomi ax3000t router MAY be bugged
          BitsPerSecond = "1G";
          Duplex = "full";
        };
      };
    };

  homelab = {
    hostname = "sou.uk.region.fogbox.uk";
    isLeader = true;
    stateDir = "/pool";
    archiveDir = "/mnt/zfs/colossus";
    router = {
      enable = true;
      linkLocal = "fe80::eaea:6aff:fe93:e79f";
      devices.wan = "enp8s0";
      devices.lan = "enp7s0";
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
      ntfy.enable = true;
      mollysocket.enable = true;
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
  environment.systemPackages = with pkgs; [ hddfancontrol ];
  services.hddfancontrol = {
    enable = true;
    settings =
      let
        platformControllerId = "`echo /sys/devices/platform/nct6775.656/hwmon/hwmon[[:print:]]`";
      in
      {
        lffBay = {
          pwmPaths = [
            "${platformControllerId}/pwm4:25:10"
            "${platformControllerId}/pwm2:25:10"
          ];
          disks = [
            "`find /dev/disk/by-id -name \"scsi*\" -and -not -name \"*-part*\" -printf \"%p \"`"
          ];
          extraArgs = [
            "--interval=30s"
            "--hybrid-monitoring"
          ];
        };
        sffBay = {
          pwmPaths = [ "${platformControllerId}/pwm1:80:55" ];
          disks = [
            "`find /dev/disk/by-id -name \"ata*\" -and -not -name \"*-part*\" -printf \"%p \"`"
          ];
          extraArgs = [
            "--interval=30s"
            "--hybrid-monitoring"
          ];
        };
      };
  };
  age.secrets.nutHtpasswd = {
    file = ../../../../secrets/prometheus/exporters/nut/htpasswd.age;
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

  age.secrets.upsmonSou.file = ../../../../secrets/upsmon/sou.age;
  power.ups = {
    enable = true;
    package = (
      pkgs.nut.override {
        withApcModbus = true;
      }
    );

    ups."SMT1500I" = {
      driver = "apc_modbus";
      port = "auto";
      directives = [
        ''vendorid = "051D"''
        ''productid = "0000"''
      ];
    };

    users.upsmon = {
      passwordFile = config.age.secrets.upsmonSou.path;
      upsmon = "primary";
    };

    upsmon.monitor."SMT1500I".user = "upsmon";
  };
}
