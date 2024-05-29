{ pkgs, config, lib, ... }:
let
  ldapname = config.homelab.services.openldap.domain;
  createSuffix = domain:
    lib.strings.concatStringsSep ","
    (map (part: "dc=${part}") (lib.strings.splitString "." domain));
  ldapSuffix = createSuffix ldapname;
  adminDn = "cn=admin,${ldapSuffix}";
  serviceOu = "ou=services,${ldapSuffix}";
in {
  config = lib.mkIf config.homelab.services.openldap.enable {
    age.secrets.ldap_admin_pw = {
      file = ../../../secrets/ldap_admin_pw.age;
      owner = "openldap";
    };
    services.openldap = {
      enable = true;
      urlList = [ "ldap://" "ldaps://" ];

      settings = {
        attrs = {
          olcLogLevel = "conns config";

          # settings for acme ssl
          olcTLSCACertificateFile = "full.pem";
          olcTLSCertificateFile = "cert.pem";
          olcTLSCertificateKeyFile = "key.pem";
          olcTLSCipherSuite = "kEECDH+aECDSA+AES:kEECDH+AES+aRSA:kEDH+aRSA+AES";
          olcTLSCRLCheck = "none";
          olcTLSVerifyClient = "never";
          # Use tls v1.3 only
          olcTLSProtocolMin = "3.4";
          # force use of tls
          olcSecurity = "tls=1";
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

            olcSuffix = ldapSuffix;

            # your admin account
            olcRootDN = adminDn;
            olcRootPW.path = config.age.secrets.ldap_admin_pw.path;

            olcAccess = [
              # custom access rules for userPassword attributes
              ''
                to attrs=userPassword
                  by self =xw
                  by anonymous auth
                  by * none
              ''
              # allow access to base by anyone
              ''
                to dn.exact=""
                  by dn.exact="${adminDn}" write
                  by * read
              ''
              # allow read on anything else
              ''
                to *
                  by self write
                  by users read
                  by * none
              ''
            ];
          };
        };
      };
    };

    # ensure openldap is launched after certificates are created
    systemd.services.openldap = {
      wants = [ "acme-${ldapname}.service" ];
      after = [ "acme-${ldapname}.service" ];
      serviceConfig = {
        LoadCredential = [
          "cert.pem:${config.security.acme.certs.${ldapname}.directory}/cert.pem"
          "key.pem:${config.security.acme.certs.${ldapname}.directory}/key.pem"
          "full.pem:${config.security.acme.certs.${ldapname}.directory}/full.pem"
        ];
      };
    };

    security.acme.certs."${ldapname}" = {};   

    networking.firewall.interfaces."eno1".allowedTCPPorts = [ 389 636 ];
  };
}
