{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    chromium
    (vivaldi.overrideAttrs (oldAttrs: {
      dontWrapQtApps = false;
      dontPatchELF = true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.kdePackages.wrapQtAppsHook ];
    }))
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

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
