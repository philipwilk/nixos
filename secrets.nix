let
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
  workstations = [
    pc
    laptop
  ];

  itxserve = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGygqcot7EsJMlGPMFiiKE6GruHaxUPwsJqBH1HiykOG root@itxserve";
  thinkcentre = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0/qDrzDMquOwPQOspR24ZVBaFcmz/uBnD0wqTcNxdX root@thinkcentre";
  rdg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3B4pG0Ztyg+D2FFt69oRRcNLWCdy79oMlQ3pjATbZ5 root@rdg";
  servers = [
    thinkcentre
    itxserve
    rdg
  ];

  s = x: "secrets/${x}.age";
in
{
  # wifi passwords
  ${s "wifiPasswords"}.publicKeys = servers ++ workstations;
  #
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
  ${s "buildbot/gh_pem"}.publicKeys = servers;
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
  ${s "prometheus/exporters/smartctl/basicAuthPassword"}.publicKeys = servers;
  ${s "prometheus/exporters/smartctl/htpasswd"}.publicKeys = servers;
  ${s "prometheus/exporters/nut/basicAuthPassword"}.publicKeys = servers;
  ${s "prometheus/exporters/nut/htpasswd"}.publicKeys = servers;
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
  # msmtp passwords
  ${s "msmtp/zedPwd"}.publicKeys = servers;
  # Wireguard
  ${s "wireguard/itxserve/private"}.publicKeys = [ itxserve ];
  ${s "wireguard/thinkcentre/private"}.publicKeys = [ thinkcentre ];
  ${s "wireguard/probook/private"}.publicKeys = [ laptop ];
  ${s "wireguard/prime/private"}.publicKeys = [ pc ];
  # Jupyterhub
  ${s "jupyter-envs"}.publicKeys = servers;
  #  gitlab-runner
  ${s "runners/csgitlab"}.publicKeys = servers;
  # upsmon user
  ${s "upsmon/sou"}.publicKeys = servers;
  # ntfy-sh envs
  ${s "ntfy/envs"}.publicKeys = servers;
  ${s "ntfy/firebase"}.publicKeys = servers;
  # Mollysocket vapid file
  ${s "mollysocket-vapid"}.publicKeys = servers;
}
