{
  ...
}:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      FastConnectable = true;
      JustWorksRepairing = "always";
      Experimental = true;
    };
  };
}
