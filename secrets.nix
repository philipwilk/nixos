let
  pc =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
  laptop =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
  workstations = [ pc laptop ];

  nixos-thinkcentre-tiny =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1WiWULvH38ludFzWf25wJ/k2oHcub8LH1rLujGPqot philip@nixos-thinkcentre-tiny";
  hp-dl380p-g8-LFF =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvP8XDrObooaEQF3vstla4XkRQJk7VdOA5kSidsnuJ/ philip@hp-dl380p-g8-LFF";
  hp-dl380p-g8-sff-2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmfy2zAyZ4Kk5QbVQ8fM19C1djXsab1Fe9hVrywW2xW philip@hp-dl380p-g8-sff-2";
  hp-dl380p-g8-sff-3 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFOE/BZJYLIUcGzfrPjG3TciXKQrFhWrm6Imwkf+vRfO philip@hp-dl380p-g8-sff-3";
  hp-dl380p-g8-sff-4 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJyHEr8Xgfvh/eLir8wWLabqSH7laWNrw7/Uo2MWT2NF philip@hp-dl380p-g8-sff-4";
  hp-dl380p-g8-sff-5 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsb8pRSRiBZaPv/7VBYnPmSMjL15dzhRwZrbcOkJ2eb philip@hp-dl380p-g8-sff-5";
  servers = [
    nixos-thinkcentre-tiny
    hp-dl380p-g8-LFF
    hp-dl380p-g8-sff-2
    hp-dl380p-g8-sff-3
    hp-dl380p-g8-sff-4
    hp-dl380p-g8-sff-5
  ];

  s = x: "secrets/${x}.age";
in {
  ${s "cloudflare"}.publicKeys = servers;
  ${s "desec"}.publicKeys = servers;
  ${s "ldap_admin_pw"}.publicKeys = servers ++ workstations;
  ${s "server_password"}.publicKeys = servers ++ workstations;
  ${s "workstation_password"}.publicKeys = workstations;
  ${s "nextcloud_admin"}.publicKeys = servers ++ workstations;
  ${s "nextcloud_sql"}.publicKeys = servers;
  ${s "factorio_password"}.publicKeys = servers ++ workstations;
  ${s "mediawiki_password"}.publicKeys = servers;
  ${s "mediawiki_sec"}.publicKeys = servers;
  ${s "mediawiki_gh_sec"}.publicKeys = servers;
  ${s "mail_ldap"}.publicKeys = servers;
  ${s "atm8"}.publicKeys = servers ++ workstations;
  ${s "mail_admin"}.publicKeys = servers;
  ${s "mail_pwd"}.publicKeys = servers;
  ${s "harmonia"}.publickeys = servers;
  ${s "buildbot/workers"}.publicKeys = servers ++ workstations;
  ${s "buildbot/worker_sec"}.publicKeys = servers;
  ${s "buildbot/oauth_sec"}.publicKeys = servers;
  ${s "buildbot/user_sec"}.publicKeys = servers;
  ${s "buildbot/webhook_sec"}.publicKeys = servers;
  ${s "hercules-ci/binaryCacheKeys"}.publicKeys = servers;
  ${s "hercules-ci/clusterJoinToken"}.publicKeys = servers;
  ${s "hercules-ci/secretsJson"}.publicKeys = servers;
  
}
