{ config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostId = "d60c7b2e";
  networking.hostName = "thinkcentre";
  system.stateVersion = "24.11"; # Did you read the comment?

  homelab = {
    hostname = "rdg.uk.region.fogbox.uk";
    net.lan = "wlp2s0";
    services.nginx.enable = true;
    services.homeAssistant.enable = true;
  };

  age.secrets.wifiPasswords.file = ../../../secrets/wifiPasswords.age;
  networking.wireless.enable = true;
  networking.wireless.secretsFile = config.age.secrets.wifiPasswords.path;
  networking.wireless.networks."Xiaomi AX3000T".pskRaw = "ext:clubhouse";

  networking.domains = {
    enable = true;
    baseDomains.${config.homelab.tld} = { };
    subDomains = {
      "rdg.uk.region.${config.homelab.tld}" = {
        a.data = "94.174.146.130";
        #aaaa.data = "";
      };
      "home.${config.homelab.tld}".a.data =
        config.networking.domains.subDomains.${config.homelab.hostname}.a.data;
    };
  };

  homelab.services.kanidm = {
    enable = true;
    domain = "testing-idm.fogbox.uk";
    backupCount = 0;
  };
}
