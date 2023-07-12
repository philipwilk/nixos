{ pkgs, config, ... }:
let
  ldapname = "ldap.fogbox.uk";
in
{
  age.secrets.mail_cf_dns_key.file = ../../secrets/mail_cf_dns_key.age;
  age.secrets.ldap_oldrtpw.file = ../../secrets/ldap_oldrtpw.age;
  services.openldap = {
    enable = true;
    urlList = [ "ldap:///" "ldaps:///" ];

    settings = {
      attrs = {
        olcLogLevel = "conns config";

        /* settings for acme ssl */
        olcTLSCACertificateFile = "/var/lib/acme/${ldapname}/full.pem";
        olcTLSCertificateFile = "/var/lib/acme/${ldapname}/cert.pem";
        olcTLSCertificateKeyFile = "/var/lib/acme/${ldapname}/key.pem";
        olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
        olcTLSCRLCheck = "none";
        olcTLSVerifyClient = "never";
        olcTLSProtocolMin = "3.1";
      };

      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
        ];

        "olcDatabase={1}mdb".attrs = {
          objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";

          olcSuffix = "dc=fogbox,dc=uk";

          /* your admin account, do not use writeText on a production system */
          olcRootDN = "cn=admin,dc=fogbox,dc=uk";
          olcRootPW = config.age.secrets.ldap_oldrtpw.path;

          olcAccess = [
            /* custom access rules for userPassword attributes */
            ''{0}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''

            /* allow read on anything else */
            ''{1}to *
                by * read''
          ];
        };
      };
    };
  };

  /* ensure openldap is launched after certificates are created */
  systemd.services.openldap = {
    wants = [ "acme-${ldapname}.service" ];
    after = [ "acme-${ldapname}.service" ];
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "wiryfuture@gmail.com";
      group = "certs";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.mail_cf_dns_key.path;
    };
    certs."${ldapname}" = {
      extraDomainNames = [ ];
    };
  };
  users.groups.certs.members = [ "openldap" ];
}
