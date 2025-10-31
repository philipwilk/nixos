{
  ...
}:
{
  imports = [
    # original modules
    ./system/lanzaboote
    ./system/iwd
    ./system/deepSleep
    ./system/plymouth
    ./system/wayland
    ./system/networkManagerResolved
    ./system/sound
    ./system/bluetooth
    ./system/security
    ./system/powerProfiles
    ./system/timezoned

    ./environment/virtualisation
    ./environment/androidTools
    ./environment/dbTools
    ./environment/nixTools
    ./environment/mediaTools
    ./environment/mediaEditingTools
    ./environment/mediaAuthoringTools
    ./environment/flashingSerialTools
    ./environment/devTools
    ./environment/fileSyncTools
    ./environment/ime
    ./environment/printingScanning
    ./environment/fonts
    ./environment/desktopTools
    ./environment/messagingTools
    ./environment/writingReadingTools
    ./environment/fonts

    ./environment/programs/kanidm
    ./environment/programs/openssh
    ./environment/programs/homeManager
    ./environment/programs/gnomeKeyring
    ./environment/programs/flatpak
    ./environment/programs/packetTracer

    # replaced modules
    # ./replaced/path/to/module.nix
  ];
}
