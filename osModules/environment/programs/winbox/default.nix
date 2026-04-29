{
  ...
}:
{
  programs.winbox = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedUDPPorts = [
    20561
  ];
}
