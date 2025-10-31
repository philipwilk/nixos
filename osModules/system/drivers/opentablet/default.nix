{
  ...
}:
{
  hardware.opentabletdriver.enable = true;
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="hidraw*", ATTRS{idVendor}=="256c", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
    SUBSYSTEM=="pci", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="0061", MODE="0666"
    SUBSYSTEM=="input", ATTRS{idVendor}=="28bd", ATTRS{idProduct}=="0094", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3434", MODE="0666"
  '';
}
