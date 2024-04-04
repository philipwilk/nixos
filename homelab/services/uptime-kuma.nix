{ config, lib, ... }: {
  config = lib.mkIf config.homelab.services.uptime-kuma.enable {
    services.uptime-kuma = {
      enable = true;
      appriseSupport = true;
      settings = { HOST = "0.0.0.0"; };
    };

    # The default port is 3001 (there is no option for it)
    networking.firewall.interfaces."eno1".allowedTCPPorts = [ 3001 ];
  };
}
