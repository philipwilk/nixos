{
  pkgs,
  config,
  lib,
  ...
}:

# How to add new users atfer creating them in services.ldif
# ldapmodify -a -x -W -f homelab/services/openldap/services.ldif -c
# Remember to set a password!
#  ldappasswd -x -W -S "uid=username,ou=users,dc=ldap,dc=fogbox,dc=uk"

let
  ldapname = config.homelab.services.openldap.domain;
  createSuffix =
    domain:
    lib.strings.concatStringsSep "," (map (part: "dc=${part}") (lib.strings.splitString "." domain));
  ldapSuffix = createSuffix ldapname;
  adminDn = "cn=admin,${ldapSuffix}";
  userOu = "ou=users,${ldapSuffix}";
  credPath = "/run/credentials/openldap.service";
in
{
  options.homelab.services.openldap = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to enable the openldap server.
      '';
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "ldap.${config.homelab.tld}";
      example = "example.com";
      description = ''
        Domain for the ldap instance.
      '';
    };
  };
  config = lib.mkIf config.homelab.services.openldap.enable {
    age.secrets.ldap_admin_pw = {
      file = ../../../../secrets/ldap_admin_pw.age;
      owner = "openldap";
    };
    services.openldap = {
      enable = true;
      urlList = [
        "ldap://"
        "ldaps://"
      ];

      settings = {
        attrs = {
          olcLogLevel = "conns config";

          # settings for acme ssl
          olcTLSCACertificateFile = "${credPath}/full.pem";
          olcTLSCertificateFile = "${credPath}/cert.pem";
          olcTLSCertificateKeyFile = "${credPath}/key.pem";
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
            objectClass = [
              "olcDatabaseConfig"
              "olcMdbConfig"
            ];

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
                  by dn.exact="uid=mail,${userOu}" read
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

    security.acme.certs."${ldapname}" = { };

    networking.firewall.interfaces.${config.homelab.net.lan}.allowedTCPPorts = [
      389
      636
    ];
  };
}
