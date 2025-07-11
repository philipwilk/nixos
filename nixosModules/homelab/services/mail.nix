{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = config.homelab.services.email.domain;
  svcDomain = "services.${domain}";
  autoDiscover = "autodiscover.${domain}";
  autoConfig = "autoconfig.${domain}";
  webmail_domain = config.homelab.services.email.web;
  mail_selfservice_domain = "selfservice.${config.homelab.tld}";
  ldapSuffix = config.services.openldap.settings.children."olcDatabase={1}mdb".attrs.olcSuffix;
  userSuffix = "ou=users,${ldapSuffix}";
  stateDir = "${config.homelab.stateDir}/stalwart-mail";
  credPath = "/run/credentials/stalwart-mail.service";
in
{
  options.homelab.services.email = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable the email server.
      '';
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = config.homelab.tld;
      example = "fogbox.uk";
      description = ''
        Domain for postfix email server.
      '';
    };
    web = lib.mkOption {
      type = lib.types.str;
      default = "mail.${config.homelab.services.email.domain}";
      example = "mail.fogbox.uk";
      description = ''
        Domain for webmail access.
      '';
    };
  };

  config = lib.mkIf config.homelab.services.email.enable {
    age.secrets = {
      mail_ldap.file = ../../../secrets/mail_ldap.age;
      mail_admin.file = ../../../secrets/mail_admin.age;
      mail_pwd.file = ../../../secrets/mail_pwd.age;
      "${domain}-rsa".file = ../../../secrets/mail/${"${domain}-rsa"}.age;
      "${domain}-ed25519".file = ../../../secrets/mail/${"${domain}-ed25519"}.age;
      "${svcDomain}-rsa".file = ../../../secrets/mail/${"${svcDomain}-rsa"}.age;
      "${svcDomain}-ed25519".file = ../../../secrets/mail/${"${svcDomain}-ed25519"}.age;
    };

    security.acme.certs = {
      "${domain}" = { };
      "${svcDomain}" = { };
    };

    systemd.services.stalwart-mail = {
      wants = [
        "acme-${domain}.service"
        "acme-${svcDomain}.service"
      ];
      after = [
        "acme-${domain}.service"
        "acme-${svcDomain}.service"
      ];
      serviceConfig = {
        LoadCredential = [
          "${domain}-cert.pem:${config.security.acme.certs.${domain}.directory}/cert.pem"
          "${domain}-key.pem:${config.security.acme.certs.${domain}.directory}/key.pem"
          "${svcDomain}-cert.pem:${config.security.acme.certs.${svcDomain}.directory}/cert.pem"
          "${svcDomain}-key.pem:${config.security.acme.certs.${svcDomain}.directory}/key.pem"
          "adminPwd:${config.age.secrets.mail_admin.path}"
          "ldapPwd:${config.age.secrets.mail_ldap.path}"
          "mailPwd:${config.age.secrets.mail_pwd.path}"
          "${domain}-rsa.key:${config.age.secrets."${domain}-rsa".path}"
          "${domain}-ed25519.key:${config.age.secrets."${domain}-ed25519".path}"
          "${svcDomain}-rsa.key:${config.age.secrets."${svcDomain}-rsa".path}"
          "${svcDomain}-ed25519.key:${config.age.secrets."${svcDomain}-ed25519".path}"
        ];
        ReadWritePaths = "${stateDir}";
      };
    };

    networking.firewall.interfaces.${config.homelab.net.lan}.allowedTCPPorts = [
      25
      465
      993
    ];

    services.nginx.virtualHosts = {
      "${mail_selfservice_domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8119";
          proxyWebsockets = true;
        };
      };
      "jmap.${domain}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8120";
          proxyWebsockets = true;
        };
      };
      "${autoConfig}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8119";
          proxyWebsockets = true;
        };
      };
      "${autoDiscover}" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8119";
          proxyWebsockets = true;
        };
      };
    };

    services.stalwart-mail = {
      enable = true;
      settings = {
        certificate.${domain} = {
          cert = "%{file:${credPath}/${domain}-cert.pem}%";
          private-key = "%{file:${credPath}/${domain}-key.pem}%";
          default = true;
        };

        certificate.${svcDomain} = {
          cert = "%{file:${credPath}/${svcDomain}-cert.pem}%";
          private-key = "%{file:${credPath}/${svcDomain}-key.pem}%";
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
            jmap = {
              bind = [ "127.0.0.1:8120" ];
              protocol = "http";
            };
          };
        };

        store = {
          data = {
            type = "rocksdb";
            path = "${stateDir}/data";
          };
          blob = {
            type = "rocksdb";
            path = "${stateDir}/blob";
          };
          fts = {
            type = "rocksdb";
            path = "${stateDir}/fts";
          };
          lookup = {
            type = "rocksdb";
            path = "${stateDir}/lookup";
          };
        };

        storage = {
          directory = "openldap";
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

        directory.openldap = {
          type = "ldap";
          url = "ldaps://ldap.fogbox.uk";
          base-dn = "${ldapSuffix}";
          timeout = "30s";
          tls.enable = true;
          bind = {
            enable = true;
            dn = "uid=mail,${userSuffix}";
            secret = "%{file:${credPath}/ldapPwd}%";
            auth = {
              enable = true;
              dn = "uid=?,${userSuffix}";
            };
          };
          filter = {
            name = "(&(objectClass=inetOrgPerson)(uid=?))";
            email = "(&(objectClass=inetOrgPerson)(|(mail=?)(mailAlias=?)(mailList=?)))";
            verify = "(&(objectClass=inetOrgPerson)(|(mail=*?*)(mailAlias=*?*)))";
            expand = "(&(objectClass=inetOrgPerson)(mailList=?))";
            domains = "(&(objectClass=inetOrgPerson)(|(mail=*@?)(mailAlias=*@?)))";
          };
          attributes = {
            name = "uid";
            class = "inetOrgPerson";
            description = [ "description" ];
            secret = "userPassword";
            email = "mail";
            # groups = [ "memberOf" ];
            # quota = "diskQuota";
          };
        };

        tracer = {
          stdout = {
            type = "stdout";
            level = "debug";
            ansi = true;
            enable = true;
          };
          journal = {
            type = "journal";
            level = "debug";
            enable = true;
          };
        };

        auth.dkim.sign = [
          {
            "if" = "is_local_domain('', sender_domain)";
            "then" = "[sender_domain + '-rsa', sender_domain + '-ed25519']";
          }
          { "else" = false; }
        ];

        signature."${domain}-rsa" = {
          private-key = "%{file:${credPath}/${domain}-rsa.key}%";
          domain = domain;
          selector = "rsa";
          headers = [
            "From"
            "To"
            "Date"
            "Subject"
            "Message-ID"
          ];
          algorithm = "rsa-sha256";
          canonicalization = "relaxed/relaxed";
          set-body-length = true;
          report = true;
        };

        signature."${domain}-ed25519" = {
          private-key = "%{file:${credPath}/${domain}-ed25519.key}%";
          domain = domain;
          selector = "ed25519";
          headers = [
            "From"
            "To"
            "Date"
            "Subject"
            "Message-ID"
          ];
          algorithm = "ed25519-sha256";
          canonicalization = "relaxed/relaxed";
          set-body-length = true;
          report = true;
        };

        signature."${svcDomain}-rsa" = {
          private-key = "%{file:${credPath}/${svcDomain}-rsa.key}%";
          domain = svcDomain;
          selector = "rsa";
          headers = [
            "From"
            "To"
            "Date"
            "Subject"
            "Message-ID"
          ];
          algorithm = "rsa-sha256";
          canonicalization = "relaxed/relaxed";
          set-body-length = true;
          report = true;
        };

        signature."${svcDomain}-ed25519" = {
          private-key = "%{file:${credPath}/${svcDomain}-ed25519.key}%";
          domain = svcDomain;
          selector = "ed25519";
          headers = [
            "From"
            "To"
            "Date"
            "Subject"
            "Message-ID"
          ];
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
