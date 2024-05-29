{
  ...
}:
{
  age.secrets.openldap_cloudflare_creds.file =
    .././secrets/openldap_cloudflare_creds.age;
  homelab = {
    enable = true;
    tld = "fogbox.uk";
    acme.mail = "philip.wilk10@gmail.com";
  };
}
