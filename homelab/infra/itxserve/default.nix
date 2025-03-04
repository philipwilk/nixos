{ config, pkgs, ... }:
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
      devices.wan = "enp5s0";
      devices.lan = "enp6s0";
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

  services.autotierfs = {
    enable = true;
    settings."/mnt/autotier/tier" = {
      Global = {
        "Log Level" = 1;
        "Tier Period" = 1000;
        "Copy Buffer Size" = "1 MiB";
      };
      "Tier 1" = {
        Path = "/pool/tier";
        Quota = "600GiB";
      };
      "Tier 2" = {
        Path = "/mnt/zfs/rust/tier";
        Quota = "1.7TiB";
      };
    };
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

  boot.kernelModules = [ "nct6775" ];
  environment.etc."fancontrol".text = ''
    INTERVAL=10
    DEVPATH=hwmon1=devices/platform/nct6775.656
    DEVNAME=hwmon1=nct6798
    FCTEMPS=
    FCFANS= hwmon1/pwm4=hwmon1/fan4_input
    MINTEMP=
    MAXTEMP=
    MINSTART=
    MINSTOP=
  '';
  environment.systemPackages = with pkgs; [ hddfancontrol ];
  services.hddfancontrol = {
    enable = true;
    logVerbosity = "TRACE";
    pwmPaths = [ "/sys/class/hwmon/hwmon1/pwm4:25:10" ];
    disks = [
      "/dev/disk/by-id/scsi-35000c500422e3433"
      "/dev/disk/by-id/scsi-35000c50056de8567"
    ];
    extraArgs = [
      "--interval=30s"
      "--min-fan-speed-prct=50"
    ];
  };
}
