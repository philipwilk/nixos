{
  ...
}:
{
  nixpkgs.overlays = [
    # add libmodbus build option to nut
    (import ./nut)
    # add cpu monitoring option
    (import ./hddfancontrol)
  ];
}
