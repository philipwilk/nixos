{ pkgs
, config
, lib
, ...
}:
let
  ldapname = config.homelab.services.openldap.domain;
  createSuffix =
    domain: lib.strings.concatStringsSep "," (map (part: "dc=${part}") (lib.strings.splitString "." domain));
  ldapSuffix = createSuffix ldapname;
in
{
  config = lib.mkIf config.homelab.services.openldap.enable {
    age.secrets.openldap_cloudflare_creds.file = ../../secrets/openldap_cloudflare_creds.age;
    age.secrets.ldap_admin_pw.file = ../../secrets/ldap_admin_pw.age;
    services.openldap = {
      enable = true;
      urlList = [ "ldap://" "ldaps://" ];

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

            olcSuffix = "${ldapSuffix}";

            /* your admin account */
            olcRootDN = "cn=admin,${ldapSuffix}";
            olcRootPW = config.age.secrets.ldap_admin_pw.path;

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
        email = config.homelab.acme.mail;
        group = "certs";
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets.openldap_cloudflare_creds.path;
      };
      certs."${ldapname}" = {
        extraDomainNames = [ ];
      };
    };
    users.groups.certs.members = [ "openldap" ];

    networking.firewall.interfaces."eno1".allowedTCPPorts = [ 389 636 ];
  };
}
