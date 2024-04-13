{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.homelab.services.sshBastion.enable {
    services = {
      openssh.ports = [ 22420 ];

      endlessh-go = {
        enable = true;
        port = 22;
        openFirewall = true;
        prometheus.enable = true;
        extraOptions = [
          "-geoip_supplier ip-api"
        ];
      };
    };
  };
}
