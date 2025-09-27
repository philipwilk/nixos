{ config, lib, ... }:
let
  domain = "buildbot.${config.homelab.tld}";
in
{
  config = lib.mkIf config.homelab.buildbot.enableMaster {
    age.secrets = {
      workers.file = ../../../secrets/buildbot/workers.age;
      oauth_sec.file = ../../../secrets/buildbot/oauth_sec.age;
      webhook_sec.file = ../../../secrets/buildbot/webhook_sec.age;
      gh_pem.file = ../../../secrets/buildbot/gh_pem.age;

      buildbot-httpbasicsecret.file = ../../../secrets/buildbot/httpbasicsecret.age;
      buildbot-httpbasicsecret.owner = "oauth2-proxy";

      buildbot-cookiesecret.file = ../../../secrets/buildbot/cookiesecret.age;
      buildbot-cookiesecret.owner = "oauth2-proxy";
      buildbot-clientsecret.file = ../../../secrets/buildbot/clientsecret.age;
      buildbot-clientsecret.owner = "oauth2-proxy";
    };

    services.buildbot-master = {
      title = domain;
      titleUrl = "https://${domain}/";
    };

    services.buildbot-nix.master = {
      enable = true;
      domain = domain;

      evalWorkerCount = 4;

      workersFile = config.age.secrets.workers.path;

      authBackend = "httpbasicauth";
      httpBasicAuthPasswordFile = config.age.secrets.buildbot-httpbasicsecret.path;

      admins = [ "philipwilk" ];
      accessMode.fullyPrivate = {
        backend = "github";
        teams = [ "fogboxuk" ];

        cookieSecretFile = config.age.secrets.buildbot-cookiesecret.path;
        clientSecretFile = config.age.secrets.buildbot-clientsecret.path;
        clientId = "Iv23liSS80uhJbjh4cQD";
      };

      github = {
        appId = 914149;
        appSecretKeyFile = config.age.secrets.gh_pem.path;

        webhookSecretFile = config.age.secrets.webhook_sec.path;
        # oauthId = "Iv23liSS80uhJbjh4cQD";
        # oauthSecretFile = config.age.secrets.oauth_sec.path;
        topic = "fogbox-buildbot";
      };
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
    };

    networking.domains.subDomains.${domain} = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };
}
