let
  pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
  workstations = [ pc laptop ];

  nixos-thinkcentre-tiny = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1WiWULvH38ludFzWf25wJ/k2oHcub8LH1rLujGPqot philip@nixos-thinkcentre-tiny";
  hp-dl380p-g8-LFF = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvP8XDrObooaEQF3vstla4XkRQJk7VdOA5kSidsnuJ/ philip@hp-dl380p-g8-LFF";
  servers = [ nixos-thinkcentre-tiny hp-dl380p-g8-LFF ];
in
{
  "openldap_cloudflare_creds.age".publicKeys = servers;
  "ldap_admin_pw.age".publicKeys = servers;
  "server_password.age".publicKeys = servers;
  "workstation_password.age".publicKeys = workstations;
  "nextcloud_admin.age".publicKeys = servers;
  "nextcloud_sql.age".publicKeys = servers;
  "factorio_password.age".publicKeys = servers;
}
