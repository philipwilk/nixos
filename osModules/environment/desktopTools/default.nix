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
    baobab
    libva-utils
    gnome-system-monitor
  ];
}
