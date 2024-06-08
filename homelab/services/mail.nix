{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = config.homelab.services.email.domain;
  webmail_domain = config.homelab.services.email.web;
  mail_selfservice_domain = "selfservice.${config.homelab.tld}";
  ldapSuffix = config.services.openldap.settings.children."olcDatabase={1}mdb".attrs.olcSuffix;
  path = "/data/stalwart-mail";
  credPath = "/run/credentials/stalwart-mail.service";
in
{
  config = lib.mkIf config.homelab.services.email.enable {
    age.secrets = {
      mail_ldap.file = ../../secrets/mail_ldap.age;
      mail_admin.file = ../../secrets/mail_admin.age;
      mail_pwd.file = ../../secrets/mail_pwd.age;
      rsa.file = ../../secrets/mail/rsa.age;
      ed25519.file = ../../secrets/mail/ed25519.age;
    };

    security.acme.certs."${domain}" = { };

    systemd.services.stalwart-mail = {
      wants = [ "acme-${domain}.service" ];
      after = [ "acme-${domain}.service" ];
      serviceConfig = {
        LoadCredential = [
          "cert.pem:${config.security.acme.certs.${domain}.directory}/cert.pem"
          "key.pem:${config.security.acme.certs.${domain}.directory}/key.pem"
          "adminPwd:${config.age.secrets.mail_admin.path}"
          "ldapPwd:${config.age.secrets.mail_ldap.path}"
          "mailPwd:${config.age.secrets.mail_pwd.path}"
          "rsa.key:${config.age.secrets.rsa.path}"
          "ed25519.key:${config.age.secrets.ed25519.path}"
        ];
        ReadWritePaths = "${path}";
      };
    };

    networking.firewall.interfaces."eno1".allowedTCPPorts = [
      25
      465
      993
    ];

    services.nginx.virtualHosts."${mail_selfservice_domain}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8119";
        proxyWebsockets = true;
      };
    };

    services.stalwart-mail = {
      enable = true;
      settings = {
        certificate.default = {
          cert = "%{file:${credPath}/cert.pem}%";
          private-key = "%{file:${credPath}/key.pem}%";
          default = true;
        };

        lookup.default.hostname = domain;

        server = {
          listener = {
            smtp = {
              bind = [ "[::]:25" ];
              protocol = "smtp";
            };
            submissions = {
              bind = [ "[::]:465" ];
              protocol = "smtp";
              tls.implicit = true;
            };
            imaptls = {
              bind = [ "[::]:993" ];
              protocol = "imap";
              tls.implicit = true;
            };
            management = {
              bind = [ "127.0.0.1:8119" ];
              protocol = "http";
            };
          };
        };
       
        store = {
          data = {
            type = "rocksdb";
            path = "${path}/data";
          };
          blob = {
            type = "rocksdb";
            path = "${path}/blob";
          };
          fts = {
            type = "rocksdb";
            path = "${path}/fts";
          };
          lookup = {
            type = "rocksdb";
            path = "${path}/lookup";
          };
        };

        storage = {
          directory = "memory";
          data = "data";
          blob = "blob";
          fts = "fts";
          lookup = "lookup";
        };

        directory.memory = {
          type = "memory";
          principals = [
            {
              name = "philipwilk";
              class = "individual";
              secret = "%{file:${credPath}/mailPwd}%";
              email = [ "philipwilk@${domain}" ];
            }
          ];
        };

        # directory.default = {
        #   type = "ldap";
        #   url = "ldaps://ldap.fogbox.uk";
        #   base-dn = "${ldapSuffix}";
        #   timeout = "5s";
        #   tls.enable = true;
        #   bind = {
        #     enable = true;
        #     dn = "uid=mail,ou=services,${ldapSuffix}";
        #     secret = "%{file:${credPath}/ldapPwd}%";
        #     auth = {
        #       enable = true;
        #       dn = "uid=?,ou=users,${ldapSuffix}";
        #     };
        #   };
        #   attributes = {
        #     name = "uid";
        #     class = "inetOrgPerson";
        #     description = [ "principalName" "description" ];
        #     secret = "userPassword";
        #     email = "mail";
        #     email-alias = "mailAlias";
        #     groups = [ "memberOf" "otherGroups" ];
        #     quota = "diskQuota";
        #   };
        # };

        tracer.stdout = {
          type = "stdout";
          level = "info";
          ansi = true;
          enable = true;
        };

        auth.dkim.sign = [
          {
            "if" = "listener != 'smtp'";
            "then" = "['rsa', 'ed25519']";
          }
          {
             "else" = false;
          }
        ];

        signature."rsa" = {
          private-key = "%{file:${credPath}/rsa.key}%";
          domain = domain;
          selector = "rsa_default";
          headers = ["From" "To" "Date" "Subject" "Message-ID"];
          algorithm = "rsa-sha256";
          canonicalization = "relaxed/relaxed";
          set-body-length = true;
          report = true;
        };

        signature."ed25519" = {
          private-key = "%{file:${credPath}/ed25519.key}%";
          domain = domain;
          selector = "ed_default";
          headers = ["From" "To" "Date" "Subject" "Message-ID"];
          algorithm = "ed25519-sha256";
          canonicalization = "relaxed/relaxed";
          set-body-length = true;
          report = true;
        };

        authentication.fallback-admin = {
          user = "admin";
          secret = "%{file:${credPath}/adminPwd}%";
        };
      };
    };
  };
}
