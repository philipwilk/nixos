{
  ...
}:
{
  imports = [
    # original modules
    ./homelab

    # replaced modules
    ./replace/services/monitoring/ups.nix
    ./replace/services/monitoring/prometheus/exporters.nix
    ./replace/services/hardware/hddfancontrol.nix
    ./replace/hardware/sensor/hddtemp.nix
  ];
}
