{
  ...
}:
{
  nixpkgs.overlays = [
    # add libmodbus build option to nut
    (import ./nut)
  ];
}
