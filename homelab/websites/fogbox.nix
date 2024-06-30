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
  options.homelab.websites.fogbox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable static fogbox server.
    '';
  };
  
  config = lib.mkIf conf.fogbox.enable {
    services.nginx.virtualHosts."${pub}" = {
      root = "/data/nginx/${pub}";
      reuseport = true;
    };
  };
}
