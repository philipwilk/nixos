{
  ...
}:
{
  age.secrets = {
    cloudflare.file = .././secrets/cloudflare.age;
    desec.file = .././secrets/desec.age;
  };
  homelab = {
    enable = true;
    tld = "fogbox.uk";
    acme.mail = "philip.wilk10@gmail.com";
  };
}
