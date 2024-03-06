{
  pkgs,
  config,
  lib,
  agenix,
  ...
}:
let
  homelab = config.homelab;
  conf = homelab.services.mediawiki;
in
{
  config = lib.mkIf conf.enable {
    age.identityPaths = [ "/home/philip/.ssh/id_ed25519" ];
    age.secrets.mediawiki_password = {
      file = ../../secrets/mediawiki_password.age;
      owner = "mediawiki";
    };
    
    networking.firewall.interfaces."eno1".allowedTCPPorts = [ (builtins.head config.services.mediawiki.httpd.virtualHost.listen).port ];
  
    services.mediawiki = {
      enable = true;
      name = conf.name;
      httpd.virtualHost = {
        hostName = conf.domain;
        adminAddr = conf.adminMail;
        listen = let p = 9999; in [
          {
            ip = "0.0.0.0";
            port = p;
            ssl = false;
          }
          {
            ip = "::";
            port = p;
            ssl = false;
          }
        ];
      };
      passwordFile = config.age.secrets.mediawiki_password.path;
    };
  };
}
