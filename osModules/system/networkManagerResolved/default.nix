{
  ...
}:
{
  services.resolved = {
    enable = true;
    dnsovertls = "opportunistic";
    extraConfig = ''
      FallbackDNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net [2620:fe::fe]#dns.quad9.net [2620:fe::9]#dns.quad9.net
    '';
  };
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
}
