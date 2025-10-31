{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    chromium
    firefox
    thunderbird
    libreoffice
    pavucontrol
    powertop
    nvtopPackages.full
  ];
}
