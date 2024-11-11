{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "staging.${config.homelab.tld}";
  imapDomain = "imap.${domain}";
  smtpDomain = "stmp.${domain}";
  postfixAdminDomain = "account.${domain}";
  dovecotCredPath = "/run/credentials/dovecot2.service";
  postfixCredPath = "/run/credentials/postfix.service";
in
{
  options.homelab.services.email.enable = lib.mkEnableOption "declarative email suite";

  config = lib.mkIf config.homelab.services.email.enable {
    # Configuration for smtps - sending mail

    # SSL cert for smtps
    security.acme.certs.${smtpDomain} = { };
    systemd.services.postfix = {
      wants = "acme-${smtpDomain}.service";
      after = "acme-${smtpDomain}.service";
      serviceConfig.LoadCredential = [
        "cert.pem:${config.security.acme.certs.${smtpDomain}.directory}/cert.pem"
        "key.pem:${config.security.acme.certs.${smtpDomain}.directory}/key.pem"
      ];
    };

    services.postfix = {
      enable = true;
      config = {
        smtp_use_tls = "yes";
        postmasterAlias = "philipwilk";
        sslKey = "${postfixCredPath}/key.pem";
        sslCert = "${postfixCredPath}/cert.pem";
        origin = domain;
        domain = domain;
        enableSubmissions = true;
        enableSmtp = false;
      };
    };

    age.secrets.server_password.file = ../secrets/server_password.age;
    services.postfixadmin = {
      enable = true;
      setupPasswordFile = config.age.secrets.server_password.path;
      hostName = postfixAdminDomain;
    };

    # Configuration for imap - receiving mail

    # SSL cert for imap
    security.acme.certs.${imapDomain} = { };
    systemd.services.dovecot2 = {
      wants = "acme-${imapDomain}.service";
      after = "acme-${imapDomain}.service";
      serviceConfig.LoadCredential = [
        "cert.pem:${config.security.acme.certs.${imapDomain}.directory}/cert.pem"
        "key.pem:${config.security.acme.certs.${imapDomain}.directory}/key.pem"
      ];
    };

    services.dovecot2 = {
      enable = true;
      mailLocation = "maildir:${config.homelab.stateDir}/spool/mail/%u";
      mailboxes = {
        All = {
          specialUse = "All";
          auto = "subscribe";
        };
        Archive = {
          specialUse = "Archive";
          auto = "subscribe";
        };
        Drafts = {
          specialUse = "Drafts";
          auto = "create";
        };
        Bin = {
          specialUse = "Trash";
          auto = "create";
          autoexpunge = "90d";
        };
        Sent = {
          specialUse = "Sent";
          auto = "create";
        };
        Spam = {
          specialUse = "Junk";
          auto = "create";
          autoexpunge = "30d";
        };
      };
      sslServerKey = "${dovecotCredPath}/key.pem";
      sslServerCert = "${dovecotCredPath}/cert.pem";
      extraConfig = ''
        ssl = required
        imapc_ssl = imaps
      '';
    };
  };
}
