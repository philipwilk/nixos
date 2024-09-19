let
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
  workstations = [
    pc
    laptop
  ];

  nixos-thinkcentre-tiny = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO+i2qFBYmULKqx0AtXWkLxRZeFqSvgs5EXChpLYzuyu root@nixos";
  itxserve = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGygqcot7EsJMlGPMFiiKE6GruHaxUPwsJqBH1HiykOG root@itxserve";
  servers = [
    nixos-thinkcentre-tiny
    itxserve
  ];

  s = x: "secrets/${x}.age";
in
{
  ${s "cloudflare"}.publicKeys = servers;
  ${s "desec"}.publicKeys = servers;
  ${s "ldap_admin_pw"}.publicKeys = servers ++ workstations;
  ${s "server_password"}.publicKeys = servers ++ workstations;
  ${s "workstation_password"}.publicKeys = workstations;
  ${s "nextcloud_admin"}.publicKeys = servers ++ workstations;
  ${s "nextcloud_sql"}.publicKeys = servers;
  ${s "factorio_password"}.publicKeys = servers ++ workstations;
  # mediawiki
  ${s "mediawiki/password"}.publicKeys = servers;
  ${s "mediawiki/gh"}.publicKeys = servers;
  ${s "mediawiki/gl"}.publicKeys = servers;
  ${s "mail_ldap"}.publicKeys = servers;
  ${s "atm8"}.publicKeys = servers ++ workstations;
  ${s "mail_admin"}.publicKeys = servers;
  ${s "mail_pwd"}.publicKeys = servers;
  # Harmonia nix cache
  ${s "harmonia"}.publicKeys = servers;
  # Buildbot
  ${s "buildbot/workers"}.publicKeys = servers ++ workstations;
  ${s "buildbot/worker_sec"}.publicKeys = servers;
  ${s "buildbot/oauth_sec"}.publicKeys = servers;
  ${s "buildbot/user_sec"}.publicKeys = servers;
  ${s "buildbot/webhook_sec"}.publicKeys = servers;
  # Hercules=ci
  ${s "hercules-ci/binaryCacheKeys"}.publicKeys = servers;
  ${s "hercules-ci/clusterJoinToken"}.publicKeys = servers;
  ${s "hercules-ci/secretsJson"}.publicKeys = servers;
  # Mail server
  ${s "mail/fogbox.uk-rsa"}.publicKeys = servers;
  ${s "mail/fogbox.uk-ed25519"}.publicKeys = servers;
  ${s "mail/services.fogbox.uk-rsa"}.publicKeys = servers;
  ${s "mail/services.fogbox.uk-ed25519"}.publicKeys = servers;
  # Vaultwarden
  ${s "vaultwarden_smtp"}.publicKeys = servers;
  # Grafana
  ${s "grafanamail"}.publicKeys = servers;
  # Prometheus
  ${s "prometheus/htpasswd"}.publicKeys = servers;
  ${s "prometheus/basicAuthPassword"}.publicKeys = servers;
  ${s "prometheus/exporters/node/basicAuthPassword"}.publicKeys = servers;
  ${s "prometheus/exporters/node/htpasswd"}.publicKeys = servers;
  ${s "prometheus/exporters/zfs/basicAuthPassword"}.publicKeys = servers;
  ${s "prometheus/exporters/zfs/htpasswd"}.publicKeys = servers;
  # Mastodon
  ${s "mastodon/smtp"}.publicKeys = servers;
  ${s "mastodon/pub"}.publicKeys = servers;
  ${s "mastodon/priv"}.publicKeys = servers;
  ${s "mastodon/otpSec"}.publicKeys = servers;
  ${s "mastodon/secBase"}.publicKeys = servers;
  # forgejo
  ${s "forgejo/smtp"}.publicKeys = servers;
  ${s "forgejo/runner_tok"}.publicKeys = servers;
  ${s "searxng/sec"}.publicKeys = servers;
  # zfs notifs
  ${s "zedMailPwd"}.publicKeys = servers;
}
