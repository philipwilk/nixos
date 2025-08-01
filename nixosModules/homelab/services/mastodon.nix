{ lib, config, ... }:
let
  credPath = "/run/credentials/mastodon.service";
in
{
  options.homelab.services.mastodon.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable the mastodon instance.
    '';
  };

  config = lib.mkIf config.homelab.services.mastodon.enable {
    age.secrets = {
      mastodonSmtp = {
        file = ../../../secrets/mastodon/smtp.age;
        owner = "mastodon";
      };
      mastodonVaPub = {
        file = ../../../secrets/mastodon/pub.age;
        owner = "mastodon";
      };
      mastodonVaPriv = {
        file = ../../../secrets/mastodon/priv.age;
        owner = "mastodon";
      };
      mastodonSecBase = {
        file = ../../../secrets/mastodon/secBase.age;
        owner = "mastodon";
      };
    };

    services.elasticsearch.enable = true;

    services.mastodon = {
      enable = true;
      localDomain = "masto.${config.homelab.tld}";
      configureNginx = true;
      elasticsearch.host = "127.0.0.1";
      smtp = {
        user = "mastodon";
        port = 465;
        host = "fogbox.uk";
        fromAddress = "mastodon@services.fogbox.uk";
        authenticate = true;
        passwordFile = config.age.secrets.mastodonSmtp.path;
        createLocally = false;
      };
      streamingProcesses = 3;
      extraConfig = {
        SMTP_SSL = "true";
        SMTP_ENABLE_STARTTLS_AUTO = "false";
        SINGLE_USER_MODE = "true";
      };
      # Secrets
      vapidPublicKeyFile = config.age.secrets.mastodonVaPub.path;
      vapidPrivateKeyFile = config.age.secrets.mastodonVaPriv.path;
      secretKeyBaseFile = config.age.secrets.mastodonSecBase.path;
    };
  };
}
