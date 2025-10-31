{
  ...
}:
{
  imports = [
    # original modules
    ./homelab

    # replaced modules
    ./replaced/services/monitoring/prometheus/exporters.nix
  ];
}
