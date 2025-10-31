{
  pkgs,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    simple-scan
  ];

  hardware.sane.enable = true;
  services = {
    printing.enable = true;
    ipp-usb.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      ipv6 = true;
    };
  };
}
