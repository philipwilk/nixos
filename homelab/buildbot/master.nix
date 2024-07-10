{ config, lib, ... }:
let
  domain = "buildbot.${config.homelab.tld}";
in
{
  config = lib.mkIf config.homelab.buildbot.enableMaster {
    age.secrets = {
      workers.file = ../../secrets/buildbot/workers.age;
      user_sec.file = ../../secrets/buildbot/user_sec.age;
      oauth_sec.file = ../../secrets/buildbot/oauth_sec.age;
      webhook_sec.file = ../../secrets/buildbot/webhook_sec.age;
    };

    services.buildbot-nix.master = {
      enable = true;
      domain = domain;

      workersFile = config.age.secrets.workers.path;

      admins = [ "philipwilk" ];
      github = {
        authType.legacy.tokenFile = config.age.secrets.user_sec.path;

        webhookSecretFile = config.age.secrets.webhook_sec.path;

        oauthId = "iv23liss80uhjbjh4cqd";
        oauthSecretFile = config.age.secrets.oauth_sec.path;
      };
    };

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
