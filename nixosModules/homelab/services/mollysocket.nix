{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.services.mollysocket;
  credPath = "/run/credentials/mollysocket.service";
  stateDir = "${config.homelab.stateDir}/mollysocket";
in
{

  options.homelab.services.mollysocket = {
    enable = lib.mkEnableOption "The mollysocket server";
  };

  config = lib.mkIf cfg.enable {
    age.secrets.mollysocket-vapid.file = ../../../secrets/mollysocket-vapid.age;

    systemd.services.mollysocket.serviceConfig = {
      LoadCredential = [
        "vapidKeyFile:${config.age.secrets.mollysocket-vapid.path}"
      ];
      ReadWritePaths = [
        stateDir
      ];
      User = "mollysocket";
    };

    users.groups.mollysocket = { };

    users.users.mollysocket = {
      isSystemUser = true;
      group = "mollysocket";
    };

    services.mollysocket = {
      enable = true;
      settings = {
        db = "${stateDir}/db.sqlite";
        allowed_endpoints = [
          config.services.ntfy-sh.settings.base-url
        ];
        vapid_key_file = "${credPath}/vapidKeyFile";
      };
    };

    services.nginx.virtualHosts."mollysocket.${config.homelab.tld}".locations."/" = {
      proxyPass = "http://${config.services.mollysocket.settings.host}:${builtins.toString config.services.mollysocket.settings.port}";
      proxyWebsockets = true;
    };

    networking.domains.subDomains."mollysocket.${config.homelab.tld}" = {
      a.data = config.networking.domains.subDomains.${config.networking.fqdn}.a.data;
      aaaa.data = config.networking.domains.subDomains.${config.networking.fqdn}.aaaa.data;
    };
  };

}
