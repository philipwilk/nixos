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
        # Apache config to rewrite the url to look nice
        extraConfig = ''
          RewriteEngine On
          RewriteRule ^/?wiki(/.*)?$ %{DOCUMENT_ROOT}/index.php [L]

          RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-f
          RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-d
          RewriteRule ^/?images/thumb/[0-9a-f]/[0-9a-f][0-9a-f]/([^/]+)/([0-9]+)px-.*$ %{DOCUMENT_ROOT}/thumb.php?f=$1&width=$2 [L,QSA,B]

          RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-f
          RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-d
          RewriteRule ^/?images/thumb/archive/[0-9a-f]/[0-9a-f][0-9a-f]/([^/]+)/([0-9]+)px-.*$ %{DOCUMENT_ROOT}/thumb.php?f=$1&width=$2&archived=1 [L,QSA,B]
        '';
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
      # Actual wiki config
      extraConfig = ''
        $wgScriptPath = "";
        $wgArticlePath = "/wiki/$1";
        $wgUsePathInfo = true;
        $wgEnableUploads = true;
        $wgGenerateThumbnailOnParse = false;
      '';
    };
  };
}
