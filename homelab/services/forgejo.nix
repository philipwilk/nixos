{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.homelab.services.forgejo.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable the forgejo git forge.
    '';
  };

  config = lib.mkIf config.homelab.services.forgejo.enable {
    age.secrets = {
      forgejo_smtp = {
        file = ../../secrets/forgejo/smtp.age;
        mode = "400";
        owner = "forgejo";
      };
      #forgejo_runner_tok = {
      #  file = ../../secrets/forgejo/runner_tok.age;
      #};
    };
    
    #systemd.services.gitea-runner-default.serviceConfig.LoadCredential = [
    #  "runner_tok:${config.age.secrets.forgejo_runner_tok.path}"
    #];
    
    services = {
      forgejo = {
        enable = true;
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "git.${config.homelab.tld}";
            ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}/";
            HTTP_PORT = 8243;
          };

          service.DISABLE_REGISTRATION = true;

          #actions = {
          #  ENABLED = true;
          #  DEFAULT_ACTIONS_URL = "github";
          #};

          mailer =
            let
              address = "forgejo@services.${config.homelab.tld}";
            in
            {
              ENABLED = true;
              SMTP_ADDR = config.homelab.tld;
              FROM = address;
              USER = "forgejo";
            };
        };
        secrets.mailer.PASSWD = config.age.secrets.forgejo_smtp.path;
      };
    

      #gitea-actions-runner = {
      #  package = pkgs.forgejo-actions-runner;
      #  instances.default = {
      #    enable = true;
      #    name = "monolith";
      #    url = config.services.forgejo.settings.server.ROOT_URL;
      #    tokenFile = "/run/credentials/gitea-runner-default.service/runner_tok";
      #    labels = [
      #      "ubuntu-latest:docker://node:16-bullseye"
      #      "ubuntu-22.04:docker://node:16-bullseye"
      #      "ubuntu-20.04:docker://node:16-bullseye"
      #      "ubuntu-18.04:docker://node:16-buster"
      #      ## optionally provide native execution on the host:
      #      "native:host"
      #    ];
      #  };
      #};

      nginx.virtualHosts."git.${config.homelab.tld}" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          client_max_body_size 512M;
        '';
        locations."/".proxyPass = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
      };
    };
  };
}
