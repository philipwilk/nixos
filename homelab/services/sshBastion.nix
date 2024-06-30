{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.homelab.services.sshBastion.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = ''
      Whether to enable ssh bastion/jumphost.
    '';
  };

  config = lib.mkIf config.homelab.services.sshBastion.enable {
    services = {
      openssh.ports = [ 22420 ];

      endlessh-go = {
        enable = true;
        port = 22;
        openFirewall = true;
        prometheus.enable = true;
        extraOptions = [ "-geoip_supplier ip-api" ];
      };
    };
  };
}
