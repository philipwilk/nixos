{
  ...
}:
{
  imports = [
    # original modules
    ./homelab

    # replaced modules
    ./replace/services/monitoring/prometheus/exporters.nix
  ];
}
