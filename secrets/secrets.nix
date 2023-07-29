let
  pc-yubikey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEDAA/uEOu7MlP1sGD4hGBxwimh2/d1ggHEHsd9bXlUQAAAABHNzaDo=";
  laptop-yubikey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIF5/jvsyRBjWZ7/uIVo5Wx2NBWZGfFZtTsQlONh5GmrUAAAABHNzaDo=";
  workstations = [ pc-yubikey laptop-yubikey ];

  nixos-thinkcentre-tiny = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1WiWULvH38ludFzWf25wJ/k2oHcub8LH1rLujGPqot philip@nixos-thinkcentre-tiny";
  hp-dl380p-g8-LFF = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvP8XDrObooaEQF3vstla4XkRQJk7VdOA5kSidsnuJ/ philip@hp-dl380p-g8-LFF";
  servers = [ nixos-thinkcentre-tiny hp-dl380p-g8-LFF ];
in
{
  "mail_cf_dns_key.age".publicKeys = [ nixos-thinkcentre-tiny ];
  "ldap_oldrtpw.age".publicKeys = [ nixos-thinkcentre-tiny ];
  "server_password.age".publicKeys = servers;
}
