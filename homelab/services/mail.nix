{ config, lib, ... }: 
let
  domain = config.homelab.services.email.domain;
  webmail_domain = config.homelab.services.email.webmail;
  ldapSuffix = config.services.openldap.settings.children."olcDatabase={1}mdb".attrs.olcSuffix;
in
{
  config = lib.mkIf config.homelab.services.email.enable {
    age.secrets.mail_ldap = {
      file = ../../secrets/mail_ldap.age;
      owner = config.services.dovecot2.user;
    };
    mailserver = {
      enable = true;
      fqdn = "mail.${domain}";
      domains = [ domain ];
      
      ldap = {
        enable = true;
        uris = [
          "ldaps://ldap.fogbox.uk"
        ];
        bind = {
          dn = "uid=mail,ou=services,${ldapSuffix}";
          passwordFile = config.age.secrets.mail_ldap.path;
        };
        postfix.uidAttribute = "uid";
        searchBase = ldapSuffix;
      };
      certificateScheme = "acme-nginx";

      fullTextSearch = {
        enable = true;
        autoIndex = true;
        indexAttachments = true;
        enforced = "body";
      };
    };
  };
}
