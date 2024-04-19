{
  config,
  lib,
  pkgs,
  ...
}:
let
  conf = config.homelab.websites;
  pub = "fogbox.uk";
in
{
  config = lib.mkIf conf.fogbox.enable {
    services.nginx.virtualHosts."${pub}" = {
      root = "/data/nginx/${pub}";
      reuseport = true;
    };
  };
}
