{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    minicom
    heimdall
    rkdeveloptool
    usbimager
    pmbootstrap
  ];
}
