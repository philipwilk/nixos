{ config
, lib
, ...
}:
{
  config = lib.mkIf config.homelab.services.vaultwarden.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
        DOMAIN = "https://vault.fogbox.uk";
        SIGNUPS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
      };
    };
    networking.firewall.interfaces."eno1".allowedTCPPorts = [ 8222 ];
  };
}
