{
  config,
  ...
}:
{
  users.users.philip.openssh.authorizedKeys.keys =
    let
      pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJEglhv4CBSjHclGcDmolVViPXFIqv9o7yTJwYaULP philip@nixowos";
      laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBv5FgfTO1OENN87FnrI3G+Sc/TNoYvOubZUXhEQrYAe philip@nixowos-laptop";
      nuc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoRccZau15aB0GGXTtgJjqtQ2RDqZr/l0/1UTnnt2M1 philip.wilk@fivium.co.uk";
      wslNuc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2cRJ8wLZJmgRcxY0nF4stDN22ynR3AHv8aUUIIC7d5 pwilk@pwilk";
      wslPrime = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9HIbuPw3GFS4HZKvx3MnHP9CIuonfEqCa3egQvZPY9 wslphilip@wslphilip";
      workstations = [
        pc
        laptop
        nuc
        wslNuc
        wslPrime
      ];
    in
    workstations;

  age.secrets.server_password.file = ../../../../secrets/server_password.age;
  users.users.philip = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.age.secrets.server_password.path;
  };

  environment.sessionVariables.EDITOR = "hx";

  hjem.users.philip.enable = true;
}
