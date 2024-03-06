let
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
  workstations = [ pc laptop ];

  nixos-thinkcentre-tiny = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1WiWULvH38ludFzWf25wJ/k2oHcub8LH1rLujGPqot philip@nixos-thinkcentre-tiny";
  hp-dl380p-g8-LFF = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvP8XDrObooaEQF3vstla4XkRQJk7VdOA5kSidsnuJ/ philip@hp-dl380p-g8-LFF";
  hp-dl380p-g8-sff-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDmfy2zAyZ4Kk5QbVQ8fM19C1djXsab1Fe9hVrywW2xW philip@hp-dl380p-g8-sff-2";
  hp-dl380p-g8-sff-3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFOE/BZJYLIUcGzfrPjG3TciXKQrFhWrm6Imwkf+vRfO philip@hp-dl380p-g8-sff-3";
  hp-dl380p-g8-sff-4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJyHEr8Xgfvh/eLir8wWLabqSH7laWNrw7/Uo2MWT2NF philip@hp-dl380p-g8-sff-4";
  hp-dl380p-g8-sff-5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsb8pRSRiBZaPv/7VBYnPmSMjL15dzhRwZrbcOkJ2eb philip@hp-dl380p-g8-sff-5";
  servers = [ nixos-thinkcentre-tiny hp-dl380p-g8-LFF hp-dl380p-g8-sff-2 hp-dl380p-g8-sff-3 hp-dl380p-g8-sff-4 hp-dl380p-g8-sff-5 ];
in
{
  "openldap_cloudflare_creds.age".publicKeys = servers;
  "ldap_admin_pw.age".publicKeys = servers ++ workstations;
  "server_password.age".publicKeys = servers ++ workstations;
  "workstation_password.age".publicKeys = workstations;
  "nextcloud_admin.age".publicKeys = servers ++ workstations;
  "nextcloud_sql.age".publicKeys = servers;
  "factorio_password.age".publicKeys = servers ++ workstations;
  "mediawiki_password.age".publicKeys = servers;
}
